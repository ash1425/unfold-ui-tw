/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    i18n: {
        locales: [`default`, `en`, `it`],
        defaultLocale: `default`,
        localeDetection: false
    },
    trailingSlash: true
}

module.exports = nextConfig
