$(document).ready(function(){
	

	$("#nb_list").delegate("li","click",function(event){
		var elem = event.target;
		var nb_id = $(elem).attr("nb_id");
		$("#nb_list li.selected").removeClass("selected");
		$(elem).addClass("selected");
		$("#show_page").empty();
		enable_nb_menu();
		disable_notes_menu();
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
		$.ajaxSetup({async:false});
		$("#show_page").load("/notebooks/new?from=ajax");
		$.ajaxSetup({async:true});
		set_show_page_form_for_ajax("notebook");
	});

	$("#edit_nb").click(function(){
		var nb_id = selected_nb_id();
		$.ajaxSetup({async:false});
		$("#show_page").load("/notebooks/" + nb_id + "/edit?from=ajax");
		$.ajaxSetup({async:true});
		set_show_page_form_for_ajax("notebook");
	});

	$("#delete_nb").click(function(){
		var nb_elem = $("#nb_list li.selected");
		var answer = confirm("Delete notebook: " + $(nb_elem).text());
		if(answer){
			$.post("/notebooks/"+ $(nb_elem).attr("nb_id"), "_method=delete", function(){
				$(nb_elem).remove();
				disable_nb_menu();
				$("#notes_list li").remove();
				disable_notes_menu();
		        $("#show_page").html("<h1>Notebook deleted successfully!</h1>");
			});		
		}
	});

	$("#add_note").click(function(){
		var nb_id = selected_nb_id();
		$.get("/notes/new?from=ajax", {notebook_id : nb_id} , function(result){
      		$.ajaxSetup({async:false});
      		$("#show_page").html(result);
      		$.ajaxSetup({async:true});
      		set_show_page_form_for_ajax("note");
    	});
	});

	$("#edit_note").click(function(){
		var note_id = $("#notes_list li.selected").attr("note_id");
		$.ajaxSetup({async:false});
		$("#show_page").load("/notes/" + note_id + "/edit?from=ajax");
		$.ajaxSetup({async:true});
		set_show_page_form_for_ajax("note");
	});
	
	$("#delete_note").click(function(){
		var note_elem = $("#notes_list li.selected");
		var answer = confirm("Delete note: " + $(note_elem).text());
		if(answer){
			$.post("/notes/"+ $(note_elem).attr("note_id"), "_method=delete", function(){
				$(note_elem).remove();
				disable_notes_menu();
		        $("#show_page").html("<h1>Note deleted successfully!</h1>");
			});		
		}
	});

	function refresh_notes_list(nb_id, callback) {
		$.ajaxSetup({async:false});
		$.get("/notebooks/" + nb_id + ".json", function(result){
			populate_notes_list_with_json(result);
		}, 'text');
		$.ajaxSetup({async:true});
		if (callback && typeof(callback) === "function") {    
    		callback();
		}		
	}

    function populate_notes_list_with_json(json){
    	$("#notes_list li").remove();
		var array = JSON.parse(json);
		var new_list = "";
		for(var x=0; x < array.length; x++) {
			var current = array[x];
			new_list = new_list.concat('<li note_id="' + current.id + '">' + current.title + '</li>\n');
		}
		$("#notes_list").html(new_list);
    }

    function refresh_notebooks_list(callback){
    	$.ajaxSetup({async:false});
    	$.get("/notebooks.json", function(result){
    		populate_notebooks_list_with_json(result);
    	}, 'text');
    	$.ajaxSetup({async:true});
		if (callback && typeof(callback) === "function") {    
    		callback();
		}	
    }

	function populate_notebooks_list_with_json(json){
    	$("#nb_list li").remove();
		var array = JSON.parse(json);
		var new_list = "";
		for(var x=0; x < array.length; x++) {
			var current = array[x];
			new_list = new_list.concat('<li nb_id="' + current.id + '">' + current.name + '</li>\n');
		}
		$("#nb_list").html(new_list);
    }

	function enable_nb_menu() {
		$("#edit_nb").removeAttr("disabled");
		$("#delete_nb").removeAttr("disabled");
		$("#add_note").removeAttr("disabled");
	}

	function disable_nb_menu() {
		$("#edit_nb").attr("disabled", "disabled");
		$("#delete_nb").attr("disabled", "disabled");
		$("#add_note").attr("disabled", "disabled");
	}

	function enable_notes_menu() {
		$("#edit_note").removeAttr("disabled");
		$("#delete_note").removeAttr("disabled");		
	}

	function disable_notes_menu() {
		$("#edit_note").attr("disabled", "disabled");
		$("#delete_note").attr("disabled",  "disabled");			
	}

	function selected_nb_id(){
		return $("#nb_list li.selected").attr("nb_id");
	} 

	function set_show_page_form_for_ajax(target){
		$("#show_page form").attr({ "data-remote":"true", "data-update-target": target });
      	$("#show_page form .actions").before('<div>\n<input id="from" name="from" type="hidden" value="ajax">\n</div>');
	}
 
	$(function() {
	  $("#show_page form[data-update-target]").live('ajax:success', function(evt, data) {
	  	var nb_id = selected_nb_id();
	  	if(data.length<=1){
	  		var target = $("#show_page form[data-update-target]").attr("data-update-target");
	  		if(target == "note"){		
		  		refresh_notes_list(nb_id, function(){
			    	var note = $("#notes_list li:first");
					note.addClass("selected");
					enable_notes_menu();    	
					$("#show_page").load("/notes/" + $(note).attr("note_id") + "?from=ajax");		
			    });    	
	  		} else if(target == "notebook"){
	  			
	  			var old_list_count = $("#nb_list li").length;
	  			var old_selected_id = $("#nb_list li.selected").attr("nb_id");
	  			refresh_notebooks_list(function(){
	  				if(old_list_count == $("#nb_list li").length){
	  					$("#nb_list li[nb_id="+ old_selected_id + "]").addClass("selected");
	  					$("#show_page").children().remove();
	  				} else {
	  					$("#nb_list li:first").addClass("selected");
	  					enable_nb_menu();
	  					disable_notes_menu();
	  					$("#show_page").children().remove();
	  				}
	  			});
	  		}
	  	}else{
	  		var target = $("#show_page form").attr("data-update-target");
	  		$.ajaxSetup({async:false});
	  		$("#show_page").html(data);
	  		$.ajaxSetup({async:true});
	  		set_show_page_form_for_ajax(target);
	  	}
	    
	  });
	});
});