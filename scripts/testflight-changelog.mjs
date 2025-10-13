#!/usr/bin/env node

import { readFileSync } from 'fs'
import https from 'https'
import jwt from 'jsonwebtoken'

const APP_BUNDLE_ID = 'app.status.mobile'

const ASC_KEY_ID = process.env.ASC_KEY_ID
const ASC_ISSUER_ID = process.env.ASC_ISSUER_ID
const ASC_KEY_FILE = process.env.ASC_KEY_FILE
const BUILD_VERSION = process.env.BUILD_VERSION
const CHANGELOG = process.env.CHANGELOG
const POLL_TIMEOUT_MINUTES = parseInt(process.env.POLL_TIMEOUT_MINUTES || '30', 10)
const POLL_INTERVAL_SECONDS = parseInt(process.env.POLL_INTERVAL_SECONDS || '30', 10)

if (!ASC_KEY_ID || !ASC_ISSUER_ID || !ASC_KEY_FILE) {
  console.error('ERROR: Missing required environment variables (ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_FILE)')
  process.exit(1)
}

if (!BUILD_VERSION || !CHANGELOG) {
  console.error('ERROR: Missing BUILD_VERSION or CHANGELOG environment variable')
  process.exit(1)
}

function generateJWT() {
  const privateKey = readFileSync(ASC_KEY_FILE, 'utf8')

  // Apple requires tokens to expire within 20 minutes for security
  // https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
  const payload = {
    iss: ASC_ISSUER_ID,
    iat: Math.floor(Date.now() / 1000),        // Issues At
    exp: Math.floor(Date.now() / 1000) + 1200, // Expires in 20 minutes
    aud: 'appstoreconnect-v1'
  }

  const token = jwt.sign(payload, privateKey, {
    algorithm: 'ES256',
    header: {
      alg: 'ES256',
      kid: ASC_KEY_ID,
      typ: 'JWT'
    }
  })

  return token
}

function apiRequest(path, options = {}) {
  return new Promise((resolve, reject) => {
    const jwt = generateJWT()

    const reqOptions = {
      hostname: 'api.appstoreconnect.apple.com',
      path: path,
      method: options.method || 'GET',
      headers: {
        'Authorization': `Bearer ${jwt}`,
        'Content-Type': 'application/json',
        ...options.headers
      }
    }

    const req = https.request(reqOptions, (res) => {
      let data = ''

      res.on('data', (chunk) => {
        data += chunk
      })

      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(data))
        } else {
          reject(new Error(`API request failed: ${res.statusCode} - ${data}`))
        }
      })
    })

    req.on('error', reject)

    if (options.body) {
      req.write(JSON.stringify(options.body))
    }

    req.end()
  })
}

async function findApp() {
  console.log(`Finding app with bundle ID: ${APP_BUNDLE_ID}`)
  // https://developer.apple.com/documentation/appstoreconnectapi/list_apps
  const response = await apiRequest(`/v1/apps?filter[bundleId]=${APP_BUNDLE_ID}`)

  if (!response.data || response.data.length === 0) {
    throw new Error(`App not found with bundle ID: ${APP_BUNDLE_ID}`)
  }

  return response.data[0].id
}

async function findBuild(appId) {
  // https://developer.apple.com/documentation/appstoreconnectapi/list_builds
  const response = await apiRequest(`/v1/builds?filter[app]=${appId}&filter[version]=${BUILD_VERSION}&sort=-uploadedDate&limit=1`)

  if (!response.data || response.data.length === 0) {
    return null
  }

  return response.data[0].id
}

async function pollForBuild(appId, timeoutMinutes = 30, pollIntervalSeconds = 30) {
  const timeoutMs = timeoutMinutes * 60 * 1000
  const pollIntervalMs = pollIntervalSeconds * 1000
  const startTime = Date.now()

  console.log(`Polling for build version ${BUILD_VERSION}...`)
  console.log(`Timeout: ${timeoutMinutes} minutes, Poll interval: ${pollIntervalSeconds} seconds`)

  let attempt = 0
  while (Date.now() - startTime < timeoutMs) {
    attempt++
    const elapsedMinutes = ((Date.now() - startTime) / 1000 / 60).toFixed(1)

    console.log(`Attempt ${attempt} (${elapsedMinutes}/${timeoutMinutes} min): Checking for build...`)

    const buildId = await findBuild(appId)

    if (buildId) {
      console.log(`Build found: ${buildId}`)
      return buildId
    }

    const remainingMs = timeoutMs - (Date.now() - startTime)
    if (remainingMs < pollIntervalMs) {
      break
    }

    console.log(`Build not ready yet, waiting ${pollIntervalSeconds} seconds...`)
    await new Promise(resolve => setTimeout(resolve, pollIntervalMs))
  }

  throw new Error(`Timeout: Build version ${BUILD_VERSION} not found after ${timeoutMinutes} minutes`)
}

async function createBetaBuildLocalization(buildId, changelog) {
  console.log(`Setting changelog for build: ${buildId}`)

  const body = {
    data: {
      type: 'betaBuildLocalizations',
      attributes: {
        locale: 'en-US',
        whatsNew: changelog
      },
      relationships: {
        build: {
          data: {
            type: 'builds',
            id: buildId
          }
        }
      }
    }
  }

  try {
    // https://developer.apple.com/documentation/appstoreconnectapi/create_a_beta_build_localization
    const response = await apiRequest('/v1/betaBuildLocalizations', {
      method: 'POST',
      body: body
    })
    console.log('Changelog set successfully')
    return response
  } catch (error) {
    if (error.message.includes('409')) {
      console.log('Localization already exists, updating...')
      return await updateBetaBuildLocalization(buildId, changelog)
    }
    throw error
  }
}

async function updateBetaBuildLocalization(buildId, changelog) {
  // https://developer.apple.com/documentation/appstoreconnectapi/list_all_beta_build_localizations_for_a_build
  const response = await apiRequest(`/v1/builds/${buildId}/betaBuildLocalizations`)

  if (!response.data || response.data.length === 0) {
    throw new Error('No existing localization found to update')
  }

  const localizationId = response.data[0].id

  const body = {
    data: {
      type: 'betaBuildLocalizations',
      id: localizationId,
      attributes: {
        whatsNew: changelog
      }
    }
  }

  // https://developer.apple.com/documentation/appstoreconnectapi/modify_a_beta_build_localization
  await apiRequest(`/v1/betaBuildLocalizations/${localizationId}`, {
    method: 'PATCH',
    body: body
  })

  console.log('Changelog updated successfully')
}

async function main() {
  try {
    console.log('Setting TestFlight changelog...')
    console.log(`Changelog: ${CHANGELOG}`)

    const appId = await findApp()
    console.log(`App ID: ${appId}`)

    const buildId = await pollForBuild(appId, POLL_TIMEOUT_MINUTES, POLL_INTERVAL_SECONDS)
    console.log(`Build ID: ${buildId}`)

    await createBetaBuildLocalization(buildId, CHANGELOG)

    console.log('TestFlight changelog set successfully')
  } catch (error) {
    console.error('Failed to set TestFlight changelog:', error.message)
    process.exit(1)
  }
}

main()
