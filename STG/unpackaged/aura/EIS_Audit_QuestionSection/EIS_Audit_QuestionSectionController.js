({
	toggleDisplaySection : function(component, event, helper) {
        var customSection = component.get("v.customSection");
        if (!customSection.display) {
            if ($A.util.isEmpty(customSection.customQuestionList)) {
                customSection.display = !customSection.display;
                helper.getCustomQuestionList(component, customSection);
            } else {
                component.set("v.customSection.display", !customSection.display);
            }
        } else {
            component.set("v.customSection.display", !customSection.display);
        }
    }
})