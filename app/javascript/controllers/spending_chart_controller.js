import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

// Register Chart.js components
Chart.register(...registerables)

export default class extends Controller {
    static values = {
        data: Object,
        select: String
    }

    connect() {
        // Destroy existing chart to ensure a fresh render
        this.destroyChart()

        const dropdown = document.querySelector(this.selectValue)
        dropdown?.addEventListener('change', this.changePeriod.bind(this))

        // Use a small delay to ensure DOM is fully ready
        requestAnimationFrame(() => {
            this.renderChart()
        })
    }

    disconnect() {
        const dropdown = document.querySelector(this.selectValue)
        dropdown?.removeEventListener('change', this.changePeriod.bind(this))

        this.destroyChart()
    }

    destroyChart() {
        this.chart?.destroy()
        this.chart = null
    }

    // Called when dropdown changes
    async changePeriod(event) {
        const days = event.target.value

        // Fetch new data from server with explicit JSON request
        const response = await fetch(`/dashboard.json?period=${days}`, {
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        })

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`)
        }

        const newData = await response.json()

        // Update the chart with new data
        this.updateChart(newData)
    }

    updateChart(newData) {
        const labels = Object.keys(newData)
        const data = Object.values(newData)

        this.chart.data.labels = labels
        this.chart.data.datasets[0].data = data
        this.chart.update()
    }

    renderChart() {
        const ctx = this.element
        const spendingData = this.dataValue
        const labels = Object.keys(spendingData)
        const data = Object.values(spendingData)

        // Store chart instance to destroy it later
        this.chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Cumulative Spending ($)',
                    data: data,
                    borderColor: 'rgb(157, 111, 87)',
                    backgroundColor: 'rgba(157, 111, 87, 0.1)',
                    fill: true,
                    tension: 0.4,
                    pointRadius: 3,
                    pointHoverRadius: 5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: {
                    duration: 750
                },
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return '$' + value
                            },
                            color: 'rgba(239, 237, 241, 0.7)'
                        },
                        grid: {
                            color: 'rgba(239, 237, 241, 0.1)'
                        }
                    },
                    x: {
                        ticks: {
                            color: 'rgba(239, 237, 241, 0.7)',
                            maxRotation: 0,
                            autoSkip: true
                        },
                        grid: {
                            color: 'rgba(239, 237, 241, 0.1)'
                        }
                    }
                }
            }
        })
    }
}