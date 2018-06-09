/**
    Super class for all triggers. 
    
    When a new trigger is created for any object, a separate handler class can be created 
    which will extend this super class. In the implementation class, the following
    virtual methods can be overridden as per need.
        beforeInsert()
        beforeUpdate()
        beforeDelete()
        afterInsert()
        afterUpdate()
        afterDelete()
        afterUndelete()
    
    Usage:
    Trigger Code: (make sure to register all trigger events even though you may not use them right away)
    -------------
        trigger GeoLevel1Trigger on Geo_Level_1__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
            new GeoLevel1TriggerHelper().process();  //just one line is all needed
        }
        
    Handler Class Code: (Create only one handler class per object. Override only the methods you are interested in.)
    -----------------           
        public class GeoLevel1TriggerHelper extends TriggerHelper {
            public override void beforeInsert() {
                //before insert logic goes here
            }
            public override void afterUpdate() {
                //after update logic goes here
            }
            etc...
        }   
    ***********************************************************
    Audit History
    ***********************************************************
    03/22/2017      Sarang Padhye             Created
    *********************************************************** 
*/
public virtual class TriggerHandler {
    protected List<SObject> oldList;
    protected List<SObject> newList;
    protected Map<Id, SObject> oldMap;
    protected Map<Id, SObject> newMap;
    protected Boolean isInsert = false;
    protected Boolean isUpdate = false;
    protected Boolean isDelete = false;
    protected Boolean isUndelete = false;
    protected Boolean isBefore = false;
    protected Boolean isAfter = false;
    protected Boolean recursionCheckNeeded;
    private Boolean skipExecution = false;

    //this must be a static variable as we have to track all processed classes in the current execution context
    public static Set<String> processedClasses = new Set<String>(); 

    public void TriggerHandler(Boolean recursionCheckNeeded) {
        this.recursionCheckNeeded = recursionCheckNeeded;
        init();
    }

    public TriggerHandler() {
        this.recursionCheckNeeded = true;  //by default recursion check is turned on
        init();
    }
    
    public void process() {
        checkRecursion();
        if (skipExecution == false) {
            if(Trigger.isBefore) {
                before();
            }
            else if(Trigger.isAfter) {
                after();
            }       
        }
    }

    /* PRIVATE METHODS */

    private void init() {
        newList = Trigger.New;
        oldList = Trigger.Old;
        newMap = Trigger.NewMap;
        oldMap = Trigger.OldMap;
    }

    private void before() {
        isBefore = true;
        if(Trigger.isInsert) {
            isInsert = true;
            beforeInsert();
        }      
        else if(Trigger.isUpdate) {
            isUpdate = true;
            beforeUpdate();
        }
        else if(Trigger.isDelete) {
            isDelete = true;
            beforeDelete();
        }       
    }

    private void after() {
        isAfter = true;
        if(Trigger.isInsert) {
            isInsert = true;
            afterInsert();
        }      
        else if(Trigger.isUpdate) {
            isUpdate = true;
            afterUpdate();
        }
        else if(Trigger.isDelete) {
            isDelete = true;
            afterDelete();
        }
        else if(Trigger.isUndelete) {
            isUndelete = true;
            afterUndelete();
        }
    }

    //If current class was already processed earlier during the current execution context, then processing will be skipped
    private void checkRecursion() {
        String className = getCurrentClassName();
        if (recursionCheckNeeded) {
            if (processedClasses.contains(className)) {
                this.skipExecution = true;
            }
        }
        processedClasses.add(className);
    }
    
    private String getCurrentClassName() {
        String context = Trigger.isBefore ? 'BEFORE:' : 'AFTER:';
        if (Trigger.isInsert) {
            context = context + ' INSERT';
        } else if (Trigger.isUpdate) {
            context = context + ' UPDATE';
        } else if (Trigger.isDelete) {
            context = context + ' DELETE';
        } else if (Trigger.isUndelete) {
            context = context + ' UNDELETE';
        }
        
        String clsNameStr = String.valueOf(this);
        String name = context + clsNameStr.substring(0, clsNameStr.indexOf(':'));
        return name;
    }


    /* PROTECTED METHODS */

    /* The following methods (one or more) can be overridden by the sub classes as per need */
    
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void beforeDelete() {}
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}
    protected virtual void afterDelete() {}
    protected virtual void afterUndelete() {}

}