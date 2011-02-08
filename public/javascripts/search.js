// Fuzzy Search
fuzzy_change = function(fuzzy, event) {
  var charCode;

  if(event && event.which){
    charCode = event.which;
  } else if(window.event){
    event = window.event;
    charCode = event.keyCode;
  }

  if (fuzzy.length < 5 && charCode != 13) {
    $("#results").html("<i style=\"font-size: small\">(type at least five characters, or hit enter to force a search)</i>");
  } else {
    fuzzy_search(fuzzy);
  }
}

fuzzy_search = function(fuzzy) {
  regexp = build_regexp(fuzzy);

  var matches = {};
  for (var track in tracks) {
      if (regexp.test(track)) {
      matches[track] = tracks[track];
    }
  }

  if (matches.length == 0) {
    $("#results").html("<i style=\"font-size: small\">No matches found.</i>");
  } else {
    render_matches(matches, regexp);
  }
}

build_regexp = function(fuzzy) {
  pattern = "\^";
  for (i = 0; i < fuzzy.length; i++) {
    pattern += "([^" + fuzzy.charAt(i) + "]*)([" + fuzzy.charAt(i) + "])";
  }
  pattern += "(.*)$";

  return new RegExp(pattern, "i");
}

// Rendering
render_matches = function(matches, regexp) {
  $("#results").html("");

  for (var track in matches) {
    $("#results").append(render_track_link(track, matches[track], regexp));
    $("#results").append("<br>");
  }
}

render_track_link = function(track_name, track_path, regexp) {
  var link = "";
  link += "<a href='/playlist/add_track?filepath=" + track_path + "'>";
  link += render_title_with_matches(track_name, regexp);
  link += "</a>";

  return link;
}

render_title_with_matches = function(track_name, regexp) {
  tokens = regexp.exec(track_name);
  var title = "";
  for (j = 1; j < tokens.length; j++) {
    if (j % 2 == 0) {
          title += "<b>" + tokens[j] + "</b>";
        } else {
          title += tokens[j];
        }
  }

  return title;
}

