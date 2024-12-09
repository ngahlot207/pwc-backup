@RestResource(urlMapping='/simpleMessage/*')
global class SimpleMessageAPI {
    
    @HttpGet
    global static String getSimpleMessage() {
        return 'this is good format';
    } 
}