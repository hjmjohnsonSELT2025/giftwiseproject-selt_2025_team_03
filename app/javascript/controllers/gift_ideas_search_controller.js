import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "results"]

    connect() {
        this.timeout = null
        this.searchURL = "/gift_ideas/search"
        this.template = document.getElementById("gift-idea-card")

        // Attach delete handlers to server-rendered gift ideas
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
                .then(data => this.renderGiftIdeas(data.gift_ideas || []))
                .catch(error => console.error('Search failed:', error))
        }, 200)
    }

    renderGiftIdeas(giftIdeas) {
        this.resultsTarget.innerHTML = ''

        if (giftIdeas.length === 0) {
            this.resultsTarget.innerHTML = `
        <div class='empty-state'>
          <p>No gift ideas found.</p>
        </div>
      `
            return
        }

        giftIdeas.forEach(gift => {
            const frag = this.template.content.cloneNode(true)

            frag.querySelector('.gift-idea-container').setAttribute('data-gift-idea-id', gift.id)
            frag.querySelector("[name='title']").textContent = gift?.title ?? ""
            frag.querySelector("[name='status']").textContent = gift?.status?.replace(/\b\w/g, l => l.toUpperCase()) ?? ""
            frag.querySelector("[name='price']").textContent = `$${gift?.price ?? 0}`
            frag.querySelector("[name='recipient']").textContent = gift?.event_recipient?.recipient_name ?? "N/A"
            frag.querySelector("[name='event']").textContent = gift?.event_recipient?.event_name ?? "N/A"

            const urlElement = frag.querySelector("[name='url']")
            if (gift.url) {
                urlElement.innerHTML = `<a href="${gift.url}" target="_blank" rel="noopener">Link</a>`
            } else {
                urlElement.textContent = "N/A"
            }

            frag.querySelector("[name='notes']").textContent = gift?.notes || "N/A"

            frag.querySelector("[data-action='view']").setAttribute('href', `/gift_ideas/${gift.id}`)
            frag.querySelector("[data-action='edit']").setAttribute('href', `/gift_ideas/${gift.id}/edit`)
            frag.querySelector(".delete-link").setAttribute('href', `/gift_ideas/${gift.id}`)

            this.resultsTarget.appendChild(frag)
        })

        this.attachDeleteHandlers()
    }

    attachDeleteHandlers() {
        const deleteLinks = this.resultsTarget.querySelectorAll('.delete-link')

        deleteLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault()

                if (!confirm('Are you sure you want to delete this gift idea?')) {
                    return
                }

                const url = link.getAttribute('href')
                const container = link.closest('.gift-idea-container')

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

                                if (this.resultsTarget.querySelectorAll('.gift-idea-container').length === 0) {
                                    this.resultsTarget.innerHTML = `
                    <div class='empty-state'>
                      <p>No gift ideas yet. Create your first gift idea to get started!</p>
                    </div>
                  `
                                }
                            }, 300)

                            console.log('Gift idea deleted successfully')
                        } else {
                            alert('Failed to delete gift idea')
                        }
                    })
                    .catch(error => {
                        alert('Failed to delete gift idea')
                        console.error('Delete failed:', error)
                    })
            })
        })
    }
}