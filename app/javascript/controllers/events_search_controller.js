import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "results"]

    connect() {
        this.timeout = null
        this.searchURL = this.inputTarget.dataset.searchUrl
        this.template = document.getElementById("event-card")

        // Attach delete handlers to server-rendered events
        this.attachDeleteHandlers()
    }

    search() {
        const query = this.inputTarget.value.trim()
        clearTimeout(this.timeout)

        this.timeout = setTimeout(() => {
            fetch(`${this.searchURL}?query=${encodeURIComponent(query)}`, {
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(response => response.json())
                .then(data => this.renderEvents(data.events || []))
                .catch(error => console.error('Search failed:', error))
        }, 200)
    }

    renderEvents(events) {
        this.resultsTarget.innerHTML = ''

        if (events.length === 0) {
            this.resultsTarget.innerHTML = `
        <div class='empty-state'>
          <p>No events found.</p>
        </div>
      `
            return
        }

        events.forEach(event => {
            const frag = this.template.content.cloneNode(true)

            frag.querySelector('.event-container').setAttribute('data-event-id', event.id)
            frag.querySelector("[name='name']").textContent = event?.name ?? ""
            frag.querySelector("[name='date']").textContent = event?.date ?? ""
            frag.querySelector("[name='location']").textContent = event?.location ?? "N/A"
            frag.querySelector("[name='theme']").textContent = event?.theme ?? "N/A"
            frag.querySelector("[name='budget']").textContent = `$${event?.budget ?? 0}`
            frag.querySelector("[name='recipients']").textContent = `${event?.recipients_count ?? 0} recipients`
            frag.querySelector("[name='days_until']").textContent = `${event?.days_until ?? 0} days`

            frag.querySelector("[data-action='view']").setAttribute('href', `/events/${event.id}`)
            frag.querySelector("[data-action='edit']").setAttribute('href', `/events/${event.id}/edit`)
            frag.querySelector(".delete-link").setAttribute('href', `/events/${event.id}`)

            this.resultsTarget.appendChild(frag)
        })

        this.attachDeleteHandlers()
    }

    attachDeleteHandlers() {
        const deleteLinks = this.resultsTarget.querySelectorAll('.delete-link')

        deleteLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault()

                if (!confirm('Are you sure you want to delete this event?')) {
                    return
                }

                const url = link.getAttribute('href')
                const container = link.closest('.event-container')

                fetch(url, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
                        'Accept': 'application/json'
                    }
                })
                    .then(response => {
                        if (response.ok) {
                            container.style.opacity = '0'
                            container.style.transition = 'opacity 0.3s'

                            setTimeout(() => {
                                container.remove()

                                if (this.resultsTarget.querySelectorAll('.event-container').length === 0) {
                                    this.resultsTarget.innerHTML = `
                    <div class='empty-state'>
                      <p>No events yet. Create your first event to get started!</p>
                    </div>
                  `
                                }
                            }, 300)

                            console.log('Event deleted successfully')
                        } else {
                            alert('Failed to delete event')
                        }
                    })
                    .catch(error => {
                        alert('Failed to delete event')
                        console.error('Delete failed:', error)
                    })
            })
        })
    }
}