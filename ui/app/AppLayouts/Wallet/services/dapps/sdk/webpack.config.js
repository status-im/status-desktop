const path = require('path');

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
};