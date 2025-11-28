$(() => {
    let $input = $("#search-recipients");
    let $results = $("#recipient-results");
    let template = document.getElementById("recipient-card");
    if (!$input.length || !$results.length || !template) return;
    let timeout = null;
    let $searchURL = $input.data('search-url');
    let colorClasses = [
        "event-color-0",
        "event-color-1",
        "event-color-2",
        "event-color-3",
        "event-color-4",
        "event-color-5"
    ];
    const eventColorMap = {};
    let colorIndex = 0;
    const eventColorClass = (name) => {
        if (!name) return colorClasses[0];
        const key = name.toLowerCase().trim();
        if (!eventColorMap[key]) {
            eventColorMap[key] = colorClasses[colorIndex % colorClasses.length];
            colorIndex +=1;
        }
        return eventColorMap[key];
    };

    const renderRecipients = (recipients) => {
        $results.empty();
        recipients.forEach((rec) => {
            const frag = template.content.cloneNode(true);
            const $frag = $(frag);
            $frag.find("[name='name']").text(`${rec?.name ?? ""}`);
            $frag.find("[name='relationship']").text(`${rec?.relationship ?? ""}`);
            
            
            const $events = $frag.find("[name='events']").text(`${rec?.events ?? ""}`);
            $events.empty();
            (rec.events || []).forEach((eventName) => {
                const $pill = $("<span></span>");
                $pill
                .addClass('event-pill')
                .addClass(eventColorClass(eventName))
                .text(eventName);

                $events.append($pill);
            });
            $frag.find("[name='likes']").text(`${rec?.likes ?? ""}`);
            $results.append(frag);
        });
    };
    $input.on('input', function() {
        const query = $(this).val().trim();
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            $.getJSON($searchURL, {query: query})
            .done(function(data) {
                renderRecipients(data.recipients || []);
            })
            .fail(function(xhr) {
                console.error(`Search failed---\n\t Status: ${xhr.status} \n\t Response: ${xhr.responseText}`);
            });
        }, 200);
    });

    const fetchAndRender = (query) => {
        $.getJSON($searchURL, { query: query || "" })
        .done((data) => {
            renderRecipients(data.recipients || []);
        })
        .fail((xhr) => {
            console.error(
                `Search failed---\n\t Status: ${xhr.status} \n\t Response: ${xhr.responseText}`
            );
        });
    };
    fetchAndRender("");
});