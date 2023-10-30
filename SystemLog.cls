/**
*  Used for logging purpose
*
*  
@author Marko Tomic (tomic.84@gmail.com)
@created 2018-23-1
*/   
public class SystemLog  {
    @TestVisible private static List<String> messages = new List<String>();
  
    private static Integer  shift   = 0;
    private static String   spaces  = '__';
  
    @TestVisible private static Boolean hasException = false;
    @testVisible private static Boolean hasError     = false;
  
    public static void push(String area) {
    
        addMessage('ENTERING ' + area);   
        shift += 1;

        if (spaces.length()/2 == shift){
            spaces = spaces + '__';
        }
    }

    public static void pop(String area) {
    
        shift = shift > 0 ? shift-1 : 0;
        addMessage('EXITING ' + area);
    }
  
    public static void pop(String area, Object returnValue) {
    
        addMessage(area + ' returns ' + String.valueOf(returnValue));
        pop(area);
    }  
  
    public static void addMessage(String message){
        addMessage(message, LoggingLevel.Info);
    }

    private static void addMessage(Object message, LoggingLevel level) {
        messages.add(spaces.substring(0,shift*2) + message);
        System.debug(level, '##### DEBUG: ' + message);
    }

    public static void addErrorMessage(String message){

        hasError = true;
        addMessage( '[ERROR] ' + message, LoggingLevel.Error);
    }

    public static void addObject(Object obj) {
        addMessage(String.valueOf(obj));
    }

    public static void addObject(String message, Object obj) {
        addMessage(message + ': ' + String.valueOf(obj));
    }

    public static void addObjects(Set<Object> objects) {
        addObjects(new List<Object>(objects), 0);
    }

    public static void addObjects(List<Object> objects) {
        addObjects(objects, 0);
    }
  
    public static void addObjects(List<Object> objects, Integer length){
    
        if (length == null){
            length = 0;
        }
        for(Object o : objects) {
            addMessage(String.valueOf(o));
            if (--length == 0){
                break; //will never happen for initial length of 0, thus all messages will be printed => not easy to read but saves code lines!
            }
        }
    }  

    public static void addException(Exception e) {
    
        hasException = true;
        addMessage('EXCEPTION ' + e.getTypeName() + ' in line ' + e.getLineNumber());
        addMessage('  STACKTRACE: '+ e.getStackTraceString());
        addMessage('  MESSAGE: ' + e.getMessage());
    }

    public static void outputLog() {
    
        String log = '';

        System.debug(LoggingLevel.Error, '#######################################################');
        System.debug(LoggingLevel.Error, '##STACKTRACE########################################');
        System.debug(LoggingLevel.Error, '#######################################################');
    
        for (String m : messages ) {
            System.debug(LoggingLevel.Error, m);
            log += m + '\n';
        }
        storeLog(log);
    }
  
    private static void storeLog(String log){
    
        System.debug(LoggingLevel.Error, '##storeLog########################################');

        SystemLog__c output      = new SystemLog__c(log__c = '', hasError__c = hasError, hasException__c = hasException);
        Attachment   att         = new Attachment();
        if (log.length() > 32768) {
            output.log__c = log.substring(0, 32768);
            att.Body = Blob.valueOf(log);
        } else {
            output.log__c = log;
        }

        insert output;
      
        if (att.Body != null) {
            att.ParentId = output.Id;
            att.Name = 'log.txt';
            //att.ContentType = 'text/plain';
            insert att;         
        }   
    }
  
    @future
    private static void storeLogAsync(String log){
    
        System.debug(LoggingLevel.Error, '##storeLogAsync########################################');
        storeLog(log);
    }
}