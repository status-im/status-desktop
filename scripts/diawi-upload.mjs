#!/usr/bin/env node

/**
 * Diawi Upload Script
 * Uploads iOS IPA files to Diawi for distribution.
 *
 * Usage: node diawi-upload.mjs <ipa_path> [comment]
 *
 * Environment variables:
 *   DIAWI_TOKEN - Required: API token for Diawi authentication
 *   VERBOSE - Optional: Set to enable verbose logging
 *   POLL_MAX_COUNT - Optional: Max polling attempts (default: 120)
 *   POLL_INTERVAL_MS - Optional: Polling interval in ms (default: 500)
 */

import https from 'node:https'
import { basename } from 'node:path'
import { createReadStream, statSync } from 'node:fs'
import { randomBytes } from 'node:crypto'

const UPLOAD_URL = 'https://upload.diawi.com/'
const STATUS_URL = 'https://upload.diawi.com/status'
const DIAWI_TOKEN = process.env.DIAWI_TOKEN
const VERBOSE = process.env.VERBOSE === 'true' || process.env.VERBOSE === '1'
const POLL_MAX_COUNT = parseInt(process.env.POLL_MAX_COUNT || '120', 10)
const POLL_INTERVAL_MS = parseInt(process.env.POLL_INTERVAL_MS || '500', 10)

const log = {
  info: (prefix, ...args) => console.log(`[INFO] ${prefix}:`, ...args),
  verbose: (prefix, ...args) => VERBOSE && console.log(`[VERBOSE] ${prefix}:`, ...args),
  warn: (prefix, ...args) => console.warn(`[WARN] ${prefix}:`, ...args),
  error: (prefix, ...args) => console.error(`[ERROR] ${prefix}:`, ...args),
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

/**
 * Perform a GET request
 */
const getRequest = async (url) => {
  return new Promise((resolve, reject) => {
    const data = []
    https.get(url, (res) => {
      res.on('error', (err) => reject(err))
      res.on('data', (chunk) => data.push(chunk))
      res.on('end', () => {
        const payload = Buffer.concat(data).toString()
        resolve({
          code: res.statusCode,
          message: res.statusMessage,
          payload: payload,
        })
      })
    }).on('error', reject)
  })
}

/**
 * Create multipart form data and upload to Diawi
 * Using native Node.js without external dependencies
 */
const uploadIpa = async (ipaPath, comment, token) => {
  const boundary = `----FormBoundary${randomBytes(16).toString('hex')}`
  const fileName = basename(ipaPath)
  const fileSize = statSync(ipaPath).size

  log.info('upload', `File: ${fileName}, Size: ${(fileSize / 1024 / 1024).toFixed(2)} MB`)

  return new Promise((resolve, reject) => {
    // Build the multipart form data parts
    const tokenPart = [
      `--${boundary}`,
      'Content-Disposition: form-data; name="token"',
      '',
      token,
    ].join('\r\n')

    const commentPart = [
      `--${boundary}`,
      'Content-Disposition: form-data; name="comment"',
      '',
      comment || fileName,
    ].join('\r\n')

    const fileHeader = [
      `--${boundary}`,
      `Content-Disposition: form-data; name="file"; filename="${fileName}"`,
      'Content-Type: application/octet-stream',
      '',
    ].join('\r\n')

    const footer = `\r\n--${boundary}--\r\n`

    // Calculate total content length
    const headerBuffer = Buffer.from(`${tokenPart}\r\n${commentPart}\r\n${fileHeader}\r\n`)
    const footerBuffer = Buffer.from(footer)
    const contentLength = headerBuffer.length + fileSize + footerBuffer.length

    const url = new URL(UPLOAD_URL)
    const options = {
      hostname: url.hostname,
      port: 443,
      path: url.pathname,
      method: 'POST',
      headers: {
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        'Content-Length': contentLength,
      },
    }

    const req = https.request(options, (res) => {
      let data = ''
      res.on('data', (chunk) => { data += chunk })
      res.on('end', () => {
        if (res.statusCode !== 200) {
          log.error('upload', `Upload failed: ${res.statusCode} ${res.statusMessage}`)
          log.error('upload', `Response: ${data}`)
          reject(new Error(`Upload failed: ${res.statusCode} ${res.statusMessage}`))
          return
        }
        try {
          const json = JSON.parse(data)
          resolve(json.job)
        } catch (e) {
          reject(new Error(`Failed to parse response: ${data}`))
        }
      })
    })

    req.on('error', (err) => {
      log.error('upload', `Request error: ${err.message}`)
      reject(err)
    })

    // Write header parts
    req.write(headerBuffer)

    // Stream the file
    const fileStream = createReadStream(ipaPath)
    fileStream.on('data', (chunk) => req.write(chunk))
    fileStream.on('end', () => {
      req.write(footerBuffer)
      req.end()
    })
    fileStream.on('error', (err) => {
      log.error('upload', `File read error: ${err.message}`)
      reject(err)
    })
  })
}

/**
 * Check the status of an upload job
 */
const checkStatus = async (jobId, token) => {
  const params = new URLSearchParams({ token, job: jobId })
  const rval = await getRequest(`${STATUS_URL}?${params.toString()}`)

  if (rval.code !== 200) {
    log.error('checkStatus', `Check query failed: ${rval.code} ${rval.message}`)
    throw new Error(`Status check failed: ${rval.code} ${rval.message}`)
  }

  return JSON.parse(rval.payload)
}

/**
 * Poll for upload completion
 */
const pollStatus = async (jobId, token) => {
  let interval = POLL_INTERVAL_MS

  for (let i = 0; i <= POLL_MAX_COUNT; i++) {
    const json = await checkStatus(jobId, token)

    switch (json.status) {
      case 2000:
        // Success
        return json
      case 2001:
        // Still processing
        log.verbose('pollStatus', `Waiting: ${json.message}`)
        break
      case 4000000:
        // Rate limited, back off
        log.warn('pollStatus', `Doubling polling interval: ${json.message}`)
        interval *= 2
        break
      default:
        log.error('pollStatus', `Error in status response: ${json.message}`)
        throw new Error(`Diawi error: ${json.message}`)
    }

    await sleep(interval)
  }

  throw new Error(`Failed to poll status after ${POLL_MAX_COUNT} retries`)
}

const main = async () => {
  const targetFile = process.argv[2]
  const comment = process.argv[3]

  if (!DIAWI_TOKEN) {
    log.error('main', 'No DIAWI_TOKEN env var provided!')
    process.exit(1)
  }

  if (!targetFile) {
    log.error('main', 'No file path provided!')
    log.error('main', 'Usage: node diawi-upload.mjs <ipa_path> [comment]')
    process.exit(1)
  }

  try {
    log.info('main', `Uploading: ${targetFile}`)
    const jobId = await uploadIpa(targetFile, comment, DIAWI_TOKEN)

    log.info('main', `Polling upload job status: ${jobId}`)
    const uploadMeta = await pollStatus(jobId, DIAWI_TOKEN)

    // Output the result as JSON (for parsing by CI)
    console.log(JSON.stringify(uploadMeta, null, 2))

    // Also output the direct link for convenience
    if (uploadMeta.link) {
      log.info('main', `Diawi URL: ${uploadMeta.link}`)
    }
  } catch (error) {
    log.error('main', error.message)
    process.exit(1)
  }
}

main()
