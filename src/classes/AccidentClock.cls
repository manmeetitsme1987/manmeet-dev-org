public with sharing class AccidentClock {
    public Integer d1 {get; set;}
    public Integer d2 {get; set;}
    public Integer h1 {get; set;}
    public Integer h2 {get; set;}
    public Integer m1 {get; set;}
    public Integer m2 {get; set;}
    
    Datetime accidentDateTime; // Datetime.newInstance(2016, 3, 6, 3, 56, 0);
    Datetime nowDateTime; // = system.now();
    
    public AccidentClock(){
        init();
    }
    
    private void init(){

        //Pearce_Settings__c settings = Pearce_Settings__c.getInstance();

        //accidentDateTime = settings.Last_Accident_Date_Time__c;
        accidentDateTime = Datetime.newInstance(2016, 3, 6, 3, 56, 0);
        nowDateTime = system.now();
        
        getDays();
        getHours();
        getMinutes();
    }        
    public PageReference calculate() {
        nowDateTime = system.now();
        init();
        return null;
    }

    public Integer getDays() {

        if(accidentDateTime==null){
            return 0;
        }

        Long dt1Long = accidentDateTime.getTime();
        Long dt2Long = nowDateTime.getTime();

        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;      
        Long days = hours / 24; 
        
        Integer tempDays = days.intValue();
        d1 = tempDays / 10;
        d2 = math.mod(tempDays,10);
        return tempDays;
    }
    public Integer getHours() {

        if(accidentDateTime==null){
            return 0;
        }

        Long dt1Long = accidentDateTime.getTime();
        Long dt2Long = nowDateTime.getTime();

        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;      
        Long days = hours / 24; 
        
        Integer tempHours = hours.intValue() - days.intValue()*24;
        h1 = tempHours / 10;
        h2 = math.mod(tempHours,10);
        return tempHours; 
    }
    public Integer getMinutes() {

        if(accidentDateTime==null){
            return 0;
        }

        Long dt1Long = accidentDateTime.getTime();
        Long dt2Long = nowDateTime.getTime();

        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;      
        Long days = hours / 24; 
        Integer tempMinutes = minutes.intValue() - hours.intValue()*60;
        m1 = tempMinutes / 10;
        m2 = math.mod(tempMinutes,10);        
        return tempMinutes;  

    }                   
 
}