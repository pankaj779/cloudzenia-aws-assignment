import express from 'express'

const app = express()
const port = process.env.PORT || 3000
const message = process.env.MESSAGE || 'Hello from Microservice'

// Response handler
const handleRequest = (req, res) => {
  res.json({
    message,
    timestamp: new Date().toISOString(),
    hostname: req.hostname
  })
}

// Handle both root and /microservice paths
app.get('/', handleRequest)
app.get('/microservice', handleRequest)
app.get('/microservice/', handleRequest)

// Health check endpoint
app.get('/healthz', (req, res) => {
  res.status(200).send('ok')
})

app.listen(port, () => {
  console.log(`Microservice running on port ${port}`)
})
