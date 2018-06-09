({
    toggleDisplaySection : function(component, event, helper) {
        var displaySection = component.get("v.displaySection");
        component.set("v.displaySection", !displaySection);
        if (displaySection) {
            var questionList_c = component.get("v.section.questionList");
            var questionIds = [];
            for (var q = 0; q < questionList_c.length; q++) {
                if (!$A.util.isEmpty(questionList_c[q].question.Id)) {
                    questionIds.push(questionList_c[q].question.Id);
                }
            }
            helper.getCorrectiveActionCounts(component, questionIds);
        }
    }
})