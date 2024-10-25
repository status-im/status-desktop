const path = require('path');
const webpack = require('webpack');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'generated'),
    module: true,
    //clean: true,
  },
  devServer: {
    static: path.join(__dirname, "."),
    compress: true,
    port: 9000,
    client: {
        overlay: false,
    }
  },
  experiments: {
    outputModule: true,
  },
  plugins: [
    // Work around for Buffer is undefined:
    // https://github.com/webpack/changelog-v5/issues/10
    new webpack.ProvidePlugin({
        Buffer: ['buffer', 'Buffer'],
    })
  ],
  resolve: {
    extensions: [ '.ts', '.js' ],
    fallback: {
        buffer: require.resolve("buffer"),
    },
  },
};