import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    edit(event) {
        const id = event.params.id;
        if (!id) {
            console.error("No ID given for edit request.");
            return;
        }
        window.location.href = `/recipients/${id}/edit`;
    }

    destory(event) {
        const id = event.params.id;
        if (!id) {
            console.error("No ID given for destroy request.");
            return;
        }
        if (!confirm("Delete this recipient?")) return;
        const token = $("meta[name='csrf-token']").attr("content");
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
            this.element.closest(".recipient-container")?.remove();
        })
        .error((err) => {
            console.error("Failed to delete recipient:", err);
        });
    }
}