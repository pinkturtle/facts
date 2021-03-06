// Generated by CoffeeScript 1.10.0
(function() {
  var Immutable, autolink, delegate, delegate2, facts, initialize, render, renderSelectedSection, saveDatabaseToLocalStorage, selectableElements, sortByTransactionTime,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  facts = Facts();

  Immutable = Facts.Immutable;

  delegate = function(event, procedure) {
    return document.addEventListener(event, procedure, true);
  };

  delegate2 = function(event, host, procedure) {
    return document.querySelector(host).addEventListener(event, procedure, true);
  };

  document.on("DOMContentLoaded", function(event) {
    var JSdatoms, serialized;
    if (serialized = localStorage.getItem("database")) {
      JSdatoms = JSON.parse(serialized);
      facts.datoms = Immutable.Stack(Immutable.fromJS(JSdatoms));
      console.info("loaded glossary from localstorage", event.type, JSdatoms);
      return initialize();
    } else {
      return d3.json("glossary.json", function(json) {
        facts.datoms = Immutable.Stack(Immutable.fromJS(json));
        console.info("loaded glossary.json", json);
        return initialize();
      });
    }
  });

  initialize = function() {
    console.info("initialize");
    facts.on("transaction", function() {
      return render();
    });
    facts.on("transaction", saveDatabaseToLocalStorage);
    return facts.advance("glossary", {
      words: ["value", "attribute", "entity", "database", "partition", "information", "outformation", "transaction", "fact", "datom", "query", "web agent"]
    });
  };

  saveDatabaseToLocalStorage = function() {
    localStorage.setItem("database", JSON.stringify(facts.database()));
    return console.info("saved database to local storage", Date.now());
  };

  delegate2("input", "form", function(event) {
    var form;
    form = event.currentTarget;
    return window.requestAnimationFrame(function() {
      var i, input, len, missingInputs, requiredInputs;
      console.info(requiredInputs = Array.apply(void 0, form.querySelectorAll("[required]:not(:disabled)")));
      for (i = 0, len = requiredInputs.length; i < len; i++) {
        input = requiredInputs[i];
        console.info("in", input.name, input.value.trim() === "");
      }
      console.info("missing", missingInputs = (function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = requiredInputs.length; j < len1; j++) {
          input = requiredInputs[j];
          if (input.value.trim() === "") {
            results.push(input);
          }
        }
        return results;
      })());
      if (missingInputs.length === 0) {
        form.classList.remove("unacceptable");
        return form.classList.add("acceptable");
      } else {
        form.classList.add("unacceptable");
        return form.classList.remove("acceptable");
      }
    });
  });

  delegate("submit", function(event) {
    var attributes, glossary;
    event.preventDefault();
    attributes = {
      word: event.target.querySelector("[name=word]").value,
      definition: event.target.querySelector("[name=definition]").value.replace(RegExp("<div>", "g"), "").replace(RegExp("</div>", "g"), "")
    };
    facts.advance(attributes.word, attributes);
    glossary = facts.query({
      "in": facts.history.last(),
      where: function(id) {
        return id === "glossary";
      }
    })[0];
    facts.advance("glossary", {
      words: glossary.words.concat(attributes.word)
    });
    return event.target.reset();
  });

  render = function() {
    var div, enter, entities, exit, glossary, link, row, sorted;
    glossary = facts.query({
      "in": facts.database(),
      where: function(id) {
        return id === "glossary";
      }
    })[0];
    entities = facts.query({
      "in": facts.database(),
      where: function(id) {
        return indexOf.call(glossary.words, id) >= 0;
      }
    });
    sorted = entities.sort(function(a, b) {
      if (a["entity id"] < b["entity id"]) {
        return -1;
      }
      if (a["entity id"] > b["entity id"]) {
        return +1;
      }
      return 0;
    });
    console.info("render", Date.now(), glossary.words, sorted);
    div = d3.select("body").selectAll("div.definition").data(sorted, function(entity) {
      return entity["entity id"];
    });
    enter = div.enter().insert("div").attr({
      "class": "word",
      "id": (function(entity) {
        return entity["entity id"];
      }),
      "data-id": (function(entity) {
        return entity["entity id"];
      })
    }).html(function(entity) {
      return "<header>" + entity["entity id"] + "</header>\n<div class=\"definition\" contenteditable=\"plaintext-only\" style=\"white-space: pre-wrap;\">" + (autolink(entity.definition, glossary)) + "</div>\n<input type=\"button\" value=\"⌦\" title=\"Take this word out of the Glossary\">";
    });
    enter.select("header").on({
      "input": function(entity) {
        return facts.advance(entity["entity id"], {
          "word": d3.event.target.innerHTML
        });
      }
    });
    enter.select(".definition").on({
      "input": function(entity) {
        console.info("entity", entity["entity id"], {
          "definition": d3.event.target.innerText
        });
        return facts.advance(entity["entity id"], {
          "definition": d3.event.target.innerText
        });
      }
    });
    enter.select("input[type=button]").on({
      "mousedown": function(entity) {
        var filtered;
        glossary = facts.query({
          "in": facts.history.last(),
          where: function(id) {
            return id === "glossary";
          }
        })[0];
        filtered = glossary.words.filter(function(word) {
          return word !== entity.word;
        });
        return facts.advance("glossary", {
          "words": filtered
        });
      }
    });
    exit = div.exit().style("height", function() {
      return getComputedStyle(this)["height"];
    }).style("opacity", function() {
      return getComputedStyle(this)["opacity"];
    }).style("overflow", "hidden").transition().duration(222).style({
      "opacity": 0
    }).transition().duration(222).style({
      "height": "0px"
    }).remove();
    link = d3.select("body > nav").selectAll("a[href]").data(sorted, function(entity) {
      return entity["entity id"];
    });
    link.enter().insert("a").attr({
      "href": function(d) {
        return "#" + d["entity id"];
      }
    }).text(function(d) {
      return d["entity id"];
    });
    link.exit().remove();
    row = d3.select("table.relevant.datoms tbody").selectAll("tr").data(facts.database().toJS());
    row.enter().insert("tr").html(function(datom) {
      return "<td class=\"entity\">" + datom[1] + "</td>\n<td class=\"attribute\">" + datom[2] + "</td>\n<td class=\"value\"><span>" + (JSON.stringify(datom[3])) + "</span></td>\n<td class=\"transaction\">" + datom[4] + "</td>";
    });
    row.html(function(datom) {
      return "<td class=\"entity\">" + datom[1] + "</td>\n<td class=\"attribute\">" + datom[2] + "</td>\n<td class=\"value\"><span>" + (JSON.stringify(datom[3])) + "</span></td>\n<td class=\"transaction\">" + datom[4] + "</td>";
    });
    row.exit().remove();
    row = d3.select("table.all.datoms tbody").selectAll("tr").data(facts.datoms.toJS());
    row.enter().insert("tr").html(function(datom) {
      return "<td class=\"entity\">" + datom[1] + "</td>\n<td class=\"attribute\">" + datom[2] + "</td>\n<td class=\"value\"><span>" + (JSON.stringify(datom[3])) + "</span></td>\n<td class=\"credence\">" + datom[0] + "</td>\n<td class=\"transaction\">" + datom[4] + "</td>";
    });
    row.html(function(datom) {
      return "<td class=\"entity\">" + datom[1] + "</td>\n<td class=\"attribute\">" + datom[2] + "</td>\n<td class=\"value\"><span>" + (JSON.stringify(datom[3])) + "</span></td>\n<td class=\"credence\">" + datom[0] + "</td>\n<td class=\"transaction\">" + datom[4] + "</td>";
    });
    return row.exit().remove();
  };

  sortByTransactionTime = function(a, b) {
    return b.transaction["record time"] - a.transaction["record time"];
  };

  autolink = function(string, glossary) {
    var glossaryWords, newString, word, words;
    words = d3.set(string.match(/\w+/g).map(function(word) {
      return word.toLowerCase();
    })).values();
    glossaryWords = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = words.length; i < len; i++) {
        word = words[i];
        if (indexOf.call(glossary.words, word) >= 0) {
          results.push(word);
        }
      }
      return results;
    })();
    newString = "" + string;
    glossaryWords.forEach(function(word) {
      return newString = newString.replace(RegExp(word, "g"), "<a class=\"word\" href=\"#" + word + "\">" + word + "</a>");
    });
    return newString;
  };

  selectableElements = "body > div[id]";

  renderSelectedSection = function(data) {
    var i, len, ref, selected;
    ref = document.querySelectorAll("*.selected");
    for (i = 0, len = ref.length; i < len; i++) {
      selected = ref[i];
      selected.classList.remove("selected");
    }
    if (data.id) {
      document.querySelector("a[href='#" + data.id + "']").classList.add("selected");
      return document.getElementById(data.id).classList.add("selected");
    }
  };

  document.addEventListener("DOMContentLoaded", function(event) {
    return window.pointer = {
      x: 0,
      y: 0
    };
  });

  document.addEventListener("mousemove", function(event) {
    var baseURL, element;
    window.pointer = {
      x: event.clientX,
      y: event.clientY
    };
    if (element = event.srcElement.closest(selectableElements)) {
      baseURL = location.toString().split("#")[0];
      if (location.hash !== ("#" + element.id)) {
        history.replaceState({}, "", baseURL + "#" + element.id);
      }
      return renderSelectedSection({
        id: element.id
      });
    }
  });

  document.addEventListener("scroll", function(event) {
    var baseURL, div, id, sections;
    sections = Array.from(document.querySelectorAll(selectableElements));
    baseURL = location.toString().split("#")[0];
    div = sections.reverse().find(function(div) {
      var distance;
      distance = div.offsetTop - window.scrollY - window.pointer.y;
      return distance < 1;
    });
    if (div === void 0) {
      if (location.hash !== void 0) {
        history.replaceState({}, "", "" + baseURL);
      }
      return renderSelectedSection({});
    } else {
      id = div.id;
      if (location.hash !== ("#" + id)) {
        history.replaceState({}, "", baseURL + "#" + id);
      }
      return renderSelectedSection({
        id: id
      });
    }
  });

}).call(this);
