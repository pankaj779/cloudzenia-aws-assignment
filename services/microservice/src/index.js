import express from 'express'

const app = express()
const port = process.env.PORT || 3000
const message = process.env.MESSAGE || 'Hello from Microservice'

app.get('/', (req, res) => {
  res.json({
    message,
    timestamp: new Date().toISOString(),
    hostname: req.hostname
  })
})

app.get('/healthz', (req, res) => {
  res.status(200).send('ok')
})

app.listen(port, () => {
  console.log(`Microservice running on port ${port}`)
})

