function instantiateFCKEditor(partIndex){
	var usedFilter = $('part_' + partIndex +'_filter_id');
	if(usedFilter.value == 'Fckeditor'){
		putInEditor(partIndex);
	}
}

function toggleEditor(partIndex){
	var filterId = $('part_' + partIndex + '_filter_id');
	if(filterId.value == 'Fckeditor'){
		putInEditor(partIndex);
	} else {
		removeEditor(partIndex);
	}
}

function removeEditor(partIndex){
	var editorInstance = FCKeditorAPI.GetInstance('part_' + partIndex + '_content');
	editorInstance.UpdateLinkedField();
	var editorContainer = $('part_' + partIndex + '_content___Frame');
	if(editorContainer){
		editorContainer.style.display = 'none';
	}
	var textareaContainer = $('part_' + partIndex + '_content');
	textareaContainer.style.display = '';
}

function putInEditor(partIndex){
	var oFCKeditor = new FCKeditor('part_'+ partIndex +'_content', '600px', '600px', 'Default');
	oFCKeditor.BasePath = "/javascripts/fckeditor/"
		oFCKeditor.Config['CustomConfigurationsPath'] = '../../fckcustom.js';
	oFCKeditor.ReplaceTextarea();
}
