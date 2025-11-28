/*
$(document).on('ready turbo:load', function() {
    
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
    let eventColorMap = {};
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
            let frag = template.content.cloneNode(true);
            let $frag = $(frag);
            $frag.find("[name='name']").text(`${rec?.name ?? ""}`);
            $frag.find("[name='relationship']").text(`${rec?.relationship ?? ""}`);
            
            
            let $events = $frag.find("[name='events']").text(`${rec?.events ?? ""}`);
            $events.empty();
            (rec.events || []).forEach((eventName) => {
                let $pill = $("<span></span>");
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
        let query = $(this).val().trim();
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
    fetchAndRender();
});
*/
const initSearch = () => {
    // jquery objects used
    const $input = $("#search-recipients");
    const $results = $("#recipient-results");
    const template = document.getElementById("recipient-card");
    const searchURL = $input.data("search-url");    // search_recipients_path
    // make sure els exist
    if (!$input.length || !$results.length || !template || !searchURL) return;
    $input.off(".recipientsSearch");
    const colorClasses = [
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
            let frag = template.content.cloneNode(true);
            let $frag = $(frag);
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
            $frag.find('.delete-link')
                .attr('href', `/recipients/${rec.id}`)
                .attr('data-turbo-method', 'delete')
                .attr('data-turbo-confirm', "Delete this recipient?");
            $results.append(frag);
        });
    };
    const fetchAndRender = (query) => {
        $.getJSON(searchURL, { query: query || "" })
        .done((data) => {
            renderRecipients(data.recipients || []);
        })
        .fail((xhr) => {
            console.error(
                `Search failed---\n\t Status: ${xhr.status} \n\t Response: ${xhr.responseText}`
            );
        });
    };
    let timeout = null;
    $input.on("input.recipientsSearch", function() {
        const query = $(this).val().trim();
        clearTimeout(timeout);
        timeout = setTimeout(() => fetchAndRender(query), 200);
    });
    fetchAndRender("");

};
initSearch();
document.addEventListener("turbo:load", initSearch);