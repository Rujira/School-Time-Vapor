$.ajax({
    url: "/api/teachers/",
    type: "GET",
    contentType: "application/json; charset=utf-8"
}).then(function (response) {
    var dataToReturn = [];
    
    for (var i=0; i < response.length; i++) {

        var tagToTransform = response[i];
        var newTag = {
        id: tagToTransform["teacherID"],
        text: tagToTransform["teacherID"],
        teacherID : tagToTransform["teacherID"]
        };
        dataToReturn.push(newTag);
    }
    
    $(".non").select2({
        placeholder: "Select Categories for the Acronym",
        // 5
        tags: false,
        // 6
        tokenSeparators: [','],
        // 7
        data: dataToReturn
    });
});
