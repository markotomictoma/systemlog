@isTest public class SystemLog_Test  {

    private static testmethod void myTest1(){
    
        SystemLog.addMessage('abc');
        SystemLog.push('LEVEL1');
        SystemLog.addMessage('def');
        SystemLog.push('LEVEL2');
        SystemLog.addMessage('ghi');
        SystemLog.pop('LEVEL2');
        SystemLog.addMessage('jklmnop qrs');
        SystemLog.pop('LEVEL1');
        SystemLog.addMessage('tuvw');
    
        System.assertEquals(9, SystemLog.messages.size());
        System.assertEquals('ENTERING LEVEL1', SystemLog.messages[1]);
        System.assertEquals('__EXITING LEVEL2', SystemLog.messages[5]);
        System.assertEquals('____ghi', SystemLog.messages[4]);
        System.assertEquals('__jklmnop qrs', SystemLog.messages[6]);
        System.assertEquals('tuvw', SystemLog.messages[8]);
    
        SystemLog.addObject(new Dummy('4711',4711,Date.newInstance(2011, 7, 4)));
    
        System.assertEquals('Dummy:[a=4711, b=4711, d=2011-07-04 00:00:00]', SystemLog.messages[9]);
    
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<100;i++) {
            accounts.add(new Account(name = 'unittest' + i));
        }
    
        SystemLog.addObjects(accounts);
    
        System.assertEquals('Account:{Name=unittest0}', SystemLog.messages[10]);
        System.assertEquals('Account:{Name=unittest99}', SystemLog.messages[109]);
    
        System.assert(!SystemLog.hasError);
        System.assert(!SystemLog.hasException);
    
        SystemLog.addErrorMessage('dummy error');

        System.assert(SystemLog.hasError);
        System.assert(!SystemLog.hasException);

        try {
            Account a;
            a.name = 'b';
        } catch (Exception e) {
            SystemLog.addException(e);
        }
    
        System.assert(SystemLog.hasError);
        System.assert(SystemLog.hasException);
    
        System.assertEquals('[ERROR] dummy error', SystemLog.messages[110]);
        System.assert(SystemLog.messages[111].startsWith('EXCEPTION System.NullPointerException in line '));
    
        SystemLog.outputLog();
    
        SystemLog__c output = [select id, log__c, (select id from Attachments) from SystemLog__c];
    
        System.assertEquals(0, output.attachments.size());
    }
  
    private static testmethod void myTest2(){
    
        //check attachment creation
        for(Integer i=0;i<110;i++) {
            SystemLog.push('LEVEL' + i);
            SystemLog.addMessage('####################################################################################################');
        }

        System.assertEquals('__________####################################################################################################', SystemLog.messages[9]);
    
        SystemLog.outputLog();
    
        SystemLog__c output = [select id,log__c, (select id from Attachments) from SystemLog__c];
    
        System.assertEquals(1, output.attachments.size());
    }
  
  private class Dummy {
    
        String a;
        Integer b;
        Date d;
    
        private Dummy(String a,Integer b,Date d){
      
          this.a = a;
          this.b = b;
          this.d = d;
        } 
    }
}