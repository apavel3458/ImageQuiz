/**
 * Requires Jquery
 */

        $.ui.autocomplete.prototype._renderItem = function( ul, item){
            var term = this.term.split(' ').join('|');
            var re = new RegExp("(" + term + ")", "gi");
            var t = item.label.replace(re,"<b>$1</b>");
            t = t.replace(/\s*\[.*\]\s*/, '');
            return $( "<li></li>" )
               .data( "item.autocomplete", item )
               .append( "<a>" + t + "</a>" )
               .appendTo( ul );
        };
            
        function setAutocomplete(field, tags, noResultsMessage) {
            $(field).autocomplete({
                 source: tags,
                 minLength: 1,
                 select: function(event, ui) { return addSearchedAnswer(event, ui); },
                 response: function(event, ui) {
                                if (ui.content.length === 0) {
                                    ui.content.push({ label: noResultsMessage });
                                }
                           }
             });
        }
        
        function addSearchedAnswer(event, ui) {
        	if (ui.item.value == "null") {
                ui.item.value = "";
                return false;
            }
            var inputField = event.target;
            var selectedChoice = ui.item.value;
            var selectedChoice = selectedChoice.replace(/\s*\[.*\]\s*/, '');
            //var parentElement = $(inputField).parent();
            //var inputFieldId = $(inputField).attr('id');
            //var ulFieldId = inputFieldId.substring(0, inputFieldId.length - "Select".length);
            //remove "Select" from the end of the field, and add UL to the end to find the UL list of selected answers
            //$('#' + ulFieldId + 'UL').tagit('createTag', selectedChoice);
            $(inputField).val(selectedChoice);
            return false;
        }