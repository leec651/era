const plugins = [ require('tailwindcss') ]

// no need unless we want to add vendor specific prefixes
// plugins.push(require('autoprefixer'))

if (process.env.NODE_ENV === 'production') {

  // reference: https://tailwindcss.com/docs/controlling-file-size/
  const purgecss = require(`@fullhuman/postcss-purgecss`)({
    // Specify the paths to all of the template files in your project
    content: [
      './src/**/*.html',
      './src/**/*.vue',
      './src/**/*.coffee',
    ],
    // Include any special characters you're using in this regular expression.
    defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || [],
  })
  plugins.push(purgecss)
}

module.exports = { plugins }
