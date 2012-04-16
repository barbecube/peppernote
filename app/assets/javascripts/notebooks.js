$(document).ready(function(){
	$("#nb_list").delegate("li","click",function(event){
		var elem = event.target;
		var nb_id = $(elem).attr("nb_id");
		$("#nb_list li.selected").removeClass("selected");
		$(elem).addClass("selected");
		$("#show_page").empty();
		enable_nb_menu();
		refresh_notes_list(nb_id);
	});

	$("#notes_list").delegate("li","click",function(event){
		var elem = event.target;
		var id = $(elem).attr("note_id");
		$("#notes_list li.selected").removeClass("selected");
		$(elem).addClass("selected");
		enable_notes_menu();
		$("#show_page").load("/notes/" + id + "?from=ajax");
	});

	$("#add_nb").click(function(){
		$("#show_page").load("/notebooks/new?from=ajax");
	});

	$("#edit_nb").click(function(){
		var nb_id = selected_nb_id();
		$("#show_page").load("/notebooks/" + nb_id + "/edit?from=ajax");
	});

	$("#delete_nb").click(function(){
		var nb_elem = $("#nb_list li.selected");
		var answer = confirm("Delete notebook: " + $(nb_elem).text());
		if(answer){
			$.post("/notebooks/"+ $(nb_elem).attr("nb_id"), "_method=delete", function(){
				$(nb_elem).remove();
				$("#notes_list li").remove();
		        $("#show_page").html("<h1>Notebook deleted successfully!</h1>");
			});		
		}
	});

	$("#add_note").click(function(){
		var nb_id = selected_nb_id();
		$("#notes_list li.selected").removeClass("selected");
		$.get("/notes/new?from=ajax", {notebook_id : nb_id} , function(result){
      		$("#show_page").html(result);
      		$("#show_page form").attr({ "data-remote":"true", "data-update-target":"note" });
    	});
	});

	$("#edit_note").click(function(){
		var note_id = $("#notes_list li.selected").attr("note_id");
		$("#show_page").load("/notes/" + note_id + "/edit?from=ajax");
	});
	
	$("#delete_note").click(function(){
		var note_elem = $("#notes_list li.selected");
		var answer = confirm("Delete note: " + $(note_elem).text());
		if(answer){
			$.post("/notes/"+ $(note_elem).attr("note_id"), "_method=delete", function(){
				$(note_elem).remove();				
		        $("#show_page").html("<h1>Note deleted successfully!</h1>");
			});		
		}
	});

	function refresh_notes_list(nb_id, callback) {
		$.get("/notebooks/" + nb_id + ".json", function(result){
			populate_with_json(result);
		}, 'text');
		callback();
	}

    function populate_with_json(json){
    	$("#notes_list li").remove();
		var array = JSON.parse(json);
		var new_list = "";
		for(var x=0; x < array.length; x++) {
			var current = array[x];
			new_list = new_list.concat('<li note_id="' + current.id + '">' + current.title + '</li>\n');
		}
		$("#notes_list").html(new_list);
    }

	function enable_nb_menu() {
		$("#edit_nb").removeAttr("disabled");
		$("#delete_nb").removeAttr("disabled");
		$("#add_note").removeAttr("disabled");
	}

	function enable_notes_menu() {
		$("#edit_note").removeAttr("disabled");
		$("#delete_note").removeAttr("disabled");		
	}

	function selected_nb_id(){
		return $("#nb_list li.selected").attr("nb_id");
	} 

	$(function() {
	  $("#show_page form[data-update-target]").live('ajax:success', function(evt, data) {
	  	var nb_id = selected_nb_id();
	    refresh_notes_list(nb_id, function(){
	    	var note = $("#notes_list li").firstChild;
    		note.addClass("selected");    	
    		$("#show_page").load("/notes/" + $(note).attr("note_id") , { from : ajax } );		
	    });    	
	  });
	});
});