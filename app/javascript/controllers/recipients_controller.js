import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
    static targets = ["search", "results", "cardTemplate", "editTemplate"]

    connect() {
        this.recipientsById = {}
        this.eventColorMap = {}
        this.colorClasses = Array.from({ length: 6 }, (_, i) => `event-color-${i}`)
        this.colorIndex = 0
        this.searchTimeout = null

        this.fetchAndRender("")
    }

    get searchUrl() {
        return this.searchTarget.dataset.searchUrl
    }

    eventColorClass(name) {
        if (!name) return this.colorClasses[0]
        const key = name.toLowerCase().trim()
        if (!this.eventColorMap[key]) {
            this.eventColorMap[key] =
                this.colorClasses[this.colorIndex % this.colorClasses.length]
            this.colorIndex += 1
        }
        return this.eventColorMap[key]
    }

    onSearch(event) {
        const query = event.target.value.trim()
        clearTimeout(this.searchTimeout)
        this.searchTimeout = setTimeout(() => {
            this.fetchAndRender(query)
        }, 200)
    }

    fetchAndRender(query = "") {
        $.getJSON(this.searchUrl, { query })
            .done((data) => {
                this.renderRecipients(data.recipients || [])
            })
            .fail((xhr) => {
                console.error(
                    `Search failed---\n\t Status: ${xhr.status} \n\t Response: ${xhr.responseText}`
                )
            })
    }

    renderRecipients(recipients) {
        this.recipientsById = {}
        const $results = $(this.resultsTarget)
        $results.empty()

        recipients.forEach((rec) => {
            this.recipientsById[rec.id] = rec

            const frag = this.cardTemplateTarget.content.cloneNode(true)
            const $frag = $(frag)
            const $card = $frag.find(".recipient-container")

            $card.attr("data-recipient-id", rec.id)

            $frag.find("[name='name']").text(rec.name || "")
            $frag.find("[name='relationship']").text(rec.relationship || "")

            const $events = $frag.find("[name='events']")
            $events.empty()
                ; (rec.events || []).forEach((eventName) => {
                    const $pill = $("<span></span>")
                        .addClass("event-pill")
                        .addClass(this.eventColorClass(eventName))
                        .text(eventName)

                    $events.append($pill)
                })

            $frag.find("[name='likes']").text(rec.likes || "")
            $frag.find("[name='dislikes']").text(rec.dislikes || "")
            const $delete = $frag.find(".delete-link")
            $delete
                .attr("href", `/recipients/${rec.id}`)
                .attr("data-turbo-method", "delete")
                .attr("data-turbo-confirm", "Delete this recipient?")

            const $edit = $frag.find(".edit-link")
            $edit.attr("data-recipients-id-param", rec.id)

            $results.append($frag)
        })
    }

    edit(event) {
        event.preventDefault()

        const id = event.params.id
        if (!id) return

        const rec = this.recipientsById[id]
        if (!rec) return

        const $card = $(event.currentTarget).closest("[data-recipient-id]")
        if (!$card.length) return

        const frag = this.editTemplateTarget.content.cloneNode(true)
        const $cardEdit = $(frag).find(".recipient-edit")

        $cardEdit.attr("data-recipient-id", id)

        const $nameIn = $cardEdit.find("input[name='name']")
        const $eventsIn = $cardEdit.find("input[name='events']")
        const $likesIn = $cardEdit.find("textarea[name='likes']")
        const $dislikesIn = $cardEdit.find("textarea[name='dislikes']")

        $nameIn.val(rec.name || "")
        $eventsIn.val((rec.events || []).join(", "))
        $likesIn.val(rec.likes || "")
        $dislikesIn.val(rec.dislikes || "")
        const $save = $cardEdit.find("[data-action*='saveEdit']")
        $save.attr("data-recipients-id-param", id)

        $card.replaceWith($cardEdit)
    }

    cancelEdit(event) {
        event.preventDefault()

        const $editCard = $(event.currentTarget).closest("[data-recipient-id]")
        if (!$editCard.length) return

        const id = $editCard.data("recipientId")
        if (!id) return

        const rec = this.recipientsById[id]
        if (!rec) return

        const frag = this.cardTemplateTarget.content.cloneNode(true)
        const $displayCard = $(frag).find(".recipient-container")

        $displayCard.attr("data-recipient-id", id)

        $displayCard.find("[name='name']").text(rec.name || "")
        $displayCard.find("[name='relationship']").text(rec.relationship || "")

        const $events = $displayCard.find("[name='events']")
        $events.empty()
            ; (rec.events || []).forEach((eventName) => {
                const $pill = $("<span></span>")
                    .addClass("event-pill")
                    .addClass(this.eventColorClass(eventName))
                    .text(eventName)
                $events.append($pill)
            })

        $displayCard.find("[name='likes']").text(rec.likes || "")
        $displayCard.find("[name='dislikes']").text(rec.dislikes || "")

        const $editLink = $displayCard.find(".edit-link")
        const $deleteLink = $displayCard.find(".delete-link")
        $editLink.attr("data-recipients-id-param", id)
        $deleteLink
            .attr("href", `/recipients/${id}`)
            .attr("data-turbo-method", "delete")
            .attr("data-turbo-confirm", "Delete this recipient?")

        $editCard.replaceWith($displayCard)
    }

saveEdit(event) {
    event.preventDefault()

    const cardNative = event.currentTarget.closest("[data-recipient-id]")
    if (!cardNative) {
        console.warn("saveEdit: no card found for button", event.currentTarget)
        return
    }

    const $editCard = $(cardNative)
    const id = $editCard.data("recipientId")
    if (!id) {
        console.warn("saveEdit: no recipientId on card", $editCard.get(0))
        return
    }

    const $nameIn   = $editCard.find("input[name='name']")
    const $eventsIn = $editCard.find("input[name='events']")
    const $likesIn  = $editCard.find("textarea[name='likes']")
    const $dislikesIn = $editCard.find("textarea[name='dislikes']")
    const $relationship = $editCard.find("input[name='relationship']")
    const $birthday = $editCard.find("input[name='birthday']") // fixed quote

    const relationship = $relationship.length ? $relationship.val().trim() : ""
    const birthday     = $birthday.length     ? $birthday.val().trim()     : ""

    const name   = ($nameIn.val()   || "").trim()
    const likes  = ($likesIn.val()  || "").trim()
    const dislikes = ($dislikesIn.val() || "").trim()
    const events = ($eventsIn.val() || "")
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean)

    $.ajax({
        url: `/recipients/${id}`,
        method: "PATCH",
        dataType: "json",
        data: {
            recipient: {
                name:  name,
                likes: likes,
                dislikes: dislikes,
                relationship: relationship,
                birthday: birthday
            }
        },
        headers: {
            "X-CSRF-Token": $("meta[name='csrf-token']").attr("content")
        }
    })
    .done((data) => {
        if (data && data.recipient) {
            this.recipientsById[id] = data.recipient
        } else if (this.recipientsById[id]) {
            this.recipientsById[id].name  = name
            this.recipientsById[id].likes = likes
            this.recipientsById[id].dislikes = dislikes
            this.recipientsById[id].relationship = relationship
            this.recipientsById[id].birthday     = birthday
        }

        const currentQuery = this.hasSearchTarget
            ? this.searchTarget.value.trim()
            : ""
        this.fetchAndRender(currentQuery)
    })
    .fail((xhr) => {
        console.error(
            "Failed to edit recipient:",
            xhr.status,
            xhr.responseText
        )
    })
    window.location.reload()
}


    destroy(event) {
        const id = event.params.id
        if (!id) {
            console.error("No ID given for destroy request.")
            return
        }
        if (!confirm("Delete this recipient?")) return
        const token = $("meta[name='csrf-token']").attr("content")
        $.ajax({
            url: `/recipients/${id}`,
            method: "DELETE",
            dataType: "text",
            data: {},
            headers: {
                "X-CSRF-Token": token
            },
        })
        .done(() => {
            this.element.closest(".recipient-container")?.remove()
        })
        .fail((err) => {
            console.error("Failed to delete recipient:", err.responseText)
        })
    }
}
