function SearchAdapter(){
    var repoUrl;

    var printShaList = function($node, shas) {
        $node.empty();
        //$node.addClass('ui segments');

        $node.append(
            '<h5 class="ui top attached tertiary header">Dependency Changes</h5>' +
            '<div id="sha-links">' +
            '</div>'
        );


        for(var i = 0; i < shas.length; i++) {
            $('#sha-links').append(
                '<div class="ui attached segment">' +
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
        $node.append(
            '<table class="ui celled striped table">'+
            '<thead><tr><th colspan="4">Licenses: ' + licenses_summary.join(', ') + '</th> </tr></thead>'+
            '<tbody id="dep-table-body"></tbody>' +
            '</table>'
        );

        for(var i = 0; i < deps.length; i++) {
            $('#dep-table-body').append(
                '<tr>'+
                '<td class="collapsing">'+ '<i class="' + getIconForSource(deps[i]) + ' icon"></i>' + deps[i].name + '</td>'+
                '<td>' + deps[i].licenses.join(', ') + '</td>'+
                '<td>' + deps[i].sha.slice(0,16) + '...</td>'+
                '<td class="right aligned collapsing">' + deps[i].version + '</td>'+
                '</tr>'
            )
        }
    };

    var getIconForSource = function(dep) {
        if (dep.source == 'GIT') {return 'git'}
        if (dep.source == 'GEM') {return 'diamond'}
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

    var submitForm = function() {
        repoUrl = $('#repo_url').val();

        $.ajax({
            url: 'commit_shas_gemfile_lock',
            method: 'get',
            data: {repo_url: repoUrl}
        }).done(function(json) {
            console.log(json);
            printShaList($('#sha-list'), json);
        })
    };

    var setLoadingForDeps = function($node) {
        $node.append('<div class="ui loading segment full-height"><p></p></div>')
    };


    this.setFormHandler = function($form) {
        var submitBtn = $form.find('div[name="submit-form"]')[0]
        var $submit = $(submitBtn);

        $submit.on('click', submitForm);

        $form.submit(function(e) {
            e.preventDefault();
            submitForm();
        })
    };

    var getDeps = function(repoUrl, sha, $dep) {
        $.ajax({
            url: 'dependencies',
            method: 'get',
            data: {utf8: "✓", repo_url: repoUrl, sha: sha, commit: "Discover Licenses"}
        }).done(function(json){
            printDepList($dep, json);
        })
    }

    this.setShaHandler = function($sha) {
        $sha.on('click', '.header', function(e){
            var sha = $(e.target).data('sha')
            var $dep = $('#dep-list');
            setLoadingForDeps($dep);
            getDeps(repoUrl, sha, $dep);
        })
    }
}

