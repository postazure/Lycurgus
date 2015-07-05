// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require semantic-ui

$(document).ready(function() {
    var searchAdapter = new SearchAdapter
    searchAdapter.setFormHandler($('form'))
    searchAdapter.setShaHandler($('#sha-list'))
});



function SearchAdapter(){
    var repoUrl;

    var printShaList = function($node, shas) {
        $node.empty();
        $node.addClass('ui segment');

        $node.append('<div class="ui relaxed divided list" id="sha-links">');
        $node.append('</div>');
        for(var i = 0; i < shas.length; i++) {
            $('#sha-links').append(
                '<div class="item">' +
                '<div class="content">' +
                '<i class="large github middle aligned icon"></i>'+
                "<a class='header truncate' data-sha=" + shas[i].sha + "'>" + shas[i].sha + "</a>" +
                '<div class="ui secondary segment">'+
                '<div class="description"><pre>' + shas[i].message + '</pre></div>' +
                '</div>' +
                '</div>' +
                '</div>'
            )
        }
    };

    var printDepList = function($node, deps) {
        $node.empty();
        var licenses_summary = getLicenseSummary(deps);

        $node.append('<div class="ui segment">Licenses: <span id="license-summary">'+ licenses_summary.join(' ') +'</span></div>')
        $node.append(deps);
        console.log(deps);
        for(var i = 0; i < deps.length; i++) {
            $node.append(
                '<div class="ui segment">' +
                '<span><i class="large diamond middle aligned icon"></i></span>'+
                '<div class="content">' +
                "<div class='header'>" + deps[i].name + " - " + deps[i].version + "</div>"+
                '<div class="license-list-'+ i +'">' + deps[i].licenses + '</div>'+
                '<pre class="description">' + deps[i].sha + '</pre>' +
                '</div>' +
                '</div>'
            )
        }
    };

    var getLicenseSummary = function(deps) {
        var licenses = [];
        for(var i = 0; i < deps.length; i++) {
            for(var j = 0; j < deps[i].licenses.length; j++)
            if (licenses.indexOf(deps[i].licenses[j]) === -1) {
                licenses.push(deps[i].licenses[j]);
            }
        }
        return licenses;
    };

    this.setFormHandler = function($form) {
        $form.submit(function(e) {
            e.preventDefault();

            repoUrl = $('#repo_url').val();

            $.ajax({
                url: 'commit_shas_gemfile_lock',
                method: 'get',
                data: {repo_url: repoUrl}
            }).done(function(json) {
                printShaList($('#sha-list'), json);
            })
        })
    };

    this.setShaHandler = function($sha) {
        $sha.on('click', '.header', function(e){
            var sha = $(e.target).data('sha')

            $.ajax({
                url: 'dependencies',
                method: 'get',
                data: {utf8: "✓", repo_url: repoUrl, sha: sha, commit: "Discover Licenses"}
            }).done(function(json){
                printDepList($('#dep-list'), json);
            })
        })
    }
}

