({
    buildTestList: function(component) {
        console.log('RevSys_ObservationSelectTestTreeGridCmpHelper.buildTestList');
        var testWithObservationsList = component.get("v.testWithObservationsList");
        var compDesc = [];
        console.log('***** RevSys_ObservationTestInfoCmpHelper.testWithObservationsList: '+testWithObservationsList.length);

        for (var i = 0; i < testWithObservationsList.length; i++) {
        	console.log('RevSys_ObservationTestInfoCmpHelper.building list');
            var test = testWithObservationsList[i];
            var config = { componentDef: "c:RevSys_ObservationTestWithEmployeeCmp", attributes: {} };
        	config.attributes = {"aura:id" : test.testNumber};
            config.attributes.testWithObs = test;
            compDesc.push([
                config.componentDef,
                config.attributes
            ]);
        }
        $A.createComponents(compDesc, function(components) {
            console.log("RevSys_ObservationSelectTestTreeGridCmpHelper - buildTestList");
            component.set("v.testList", components);
        });
    },
})