//custom functions examples.

/**@author dreddyag
 * Performs Vertical and Horizonal Lookup values.
 * @customfunction vh_lookup
 * @param {string} valueRange range of cells to perform lookup
 * @param {string} vlookupVal vlookup value 
 * @param {string} hlookupVal Optional string hlookupvalue
 * @returns {string} vhlookupvalue 
 */
 async function vh_lookup(valueRange,vlookupVal,hlookupVal){
  try {
  console.log("vh_lookup custom function execution started")
  let vhlookupvalue=""
  let invalidLookup="Lookup value not found"

  var context= new Excel.RequestContext();
  let sheet = context.workbook.worksheets.getActiveWorksheet();
  let lookupRange = sheet.getRange(valueRange);
  var startRangeRow=valueRange.split(":")[0][1]-1 //to get reference from original value as range gets resized.
  lookupRange.load(["rowCount", "columnCount","values","rowIndex","columnIndex"]);
  context.trackedObjects.add(lookupRange)
  await context.sync();

  let rowCount=lookupRange.rowCount;
  let colCount=lookupRange.columnCount;

  if(hlookupVal=="" && (colCount==2)){
    console.log("Vlookup")
    try{
    let matchRange=lookupRange.getAbsoluteResizedRange(rowCount,1).find(vlookupVal,{completeMatch: true})
    matchRange.load(["columnIndex","rowIndex","values","rowCount"])
    await context.sync();
    console.log(lookupRange.values)
    vhlookupvalue=lookupRange.values[matchRange.rowIndex-startRangeRow][1]
    }catch(e){
      console.log("Vlookup not found");
      console.log(e.message)
      vhlookupvalue=invalidLookup
    }
  }else if(hlookupVal=="" && (rowCount==2)){
    try{
    console.log("Hlookup")
    let matchRangehlookup=lookupRange.getAbsoluteResizedRange(1,colCount).find(vlookupVal,{completeMatch: true})
    matchRangehlookup.load(["columnIndex","rowIndex","rowCount","values"])
    await context.sync();
    vhlookupvalue=lookupRange.values[1][matchRangehlookup.columnIndex]
    }catch(e){
      console.log("Hlookup not found");
      console.log(e.message)
      vhlookupvalue=invalidLookup
    }
  }else if(hlookupVal!=""){
    try{
    console.log("VHlookup")
    let matchRangeverlookup=lookupRange.getAbsoluteResizedRange(rowCount,1).find(vlookupVal,{completeMatch: true})
    let matchRangehorlookup=lookupRange.getAbsoluteResizedRange(1,colCount).find(hlookupVal,{completeMatch: true})
    matchRangeverlookup.load(["columnIndex","rowIndex"])
    matchRangehorlookup.load(["columnIndex","rowIndex"])
    await context.sync();
    vhlookupvalue=lookupRange.values[matchRangeverlookup.rowIndex-startRangeRow][matchRangehorlookup.columnIndex]
    }catch(e){
      console.log("VHlookup not found");
      console.log(e.message)
      vhlookupvalue=invalidLookup
    }
  }else{
    console.log("None of the conditions are met , Lookup value not found");
    vhlookupvalue=invalidLookup
}
  return vhlookupvalue;
} catch (error) {
  console.log(error.code)
  console.log(error.message)
  console.log("error occured");
}
}


/**
 * Returns the number spelled out
 * @customfunction 
 * @author dreddyag
 * @param {number} myNumber the value to be converted to words
 * @param {number} [scalingFactor] Optional scaling factor to apply to myNumber
 * @param {string} [currencyText] Optional text to append to the converted string, default is Dollars
 * @param {number} [showCents] Optional handling to spell out cents.
 * @return {string} converted number to string.
 */
async function SPELLNUMBER(myNumber, scalingFactor, currencyText, showCents) {
    try {
        currencyText = currencyText && currencyText != "" ? currencyText : "Dollars";
        myNumber=Math.abs(myNumber)
        if (scalingFactor) {
            //To retain the trailing zeroes with is removed after Multiplication.
            myNumber = (myNumber * scalingFactor).toFixed(2);
        }
        //Check the number to see if there are Cents
        var splitted = myNumber.toString().split(".");
        var num_first = splitted[0];
        var num_sec = 0;
        if (splitted.length > 1) {
            num_sec = splitted[1];
            num_sec = Number(String(num_sec).slice(0, 2)); //Retain only 2 decimal values after decimal places.
        }
        //Number contains Cents and print it.
        if (showCents && num_sec != 0) {
            var num_words_first = format_currency(num_first);
            var num_words_sec = format_currency(num_sec);
            num_words = num_words_first + " " + currencyText + " and " + num_words_sec + " Cents";
        } //Prints the number without Cents
        else {
            var num_words = format_currency(num_first);
            num_words = num_words + " " + currencyText + " ";
        }
        return num_words;
    } catch (error) {
        console.log('Error: ' + error.message);
        console.log(error);
        console.log(error.stack);

        return '!ERROR';

    }
}


/**
 * Returns the number in certain format
 * @customfunction 
 * @author dreddyag
 * @param {number} myNumber the value to be converted to words
 * @param {number} [scalingFactor] Optional scaling factor to apply to myNumber
 * @param {string} [currencySymbol] Optional text to append the Currency Symbol
 * @return {string} converted number to string.
 */
async function REPORTNUMBER(myNumber, scalingFactor, currencySymbol) {
    try {
         //If Symbol not passed then its empty.
        currencySymbol = currencySymbol && currencySymbol != "" ? currencySymbol : " ";
        var reportNumberText = "";
        if (scalingFactor) {
            //To retain the trailing zeroes.
            myNumber = (myNumber * scalingFactor).toFixed(1);
        }
        var n = myNumber;
        //Logic for numbers within 10
        if (Math.round(Math.abs(myNumber)) < 10) {
            if (n < 0) {
                console.log("Negetive number");
                reportNumberText = currencySymbol + "(" + spell_number(Math.abs(Math.round(n))) + ")";
            }
            else {
                reportNumberText = currencySymbol + spell_number(Math.round(n));
            }
        } //Logic for number within 1000
        else if (Math.round(Math.abs(n)) < 1000) {
            if (n < 0) {
                reportNumberText = currencySymbol + "(" + Math.round(Math.abs(n)) + ")";
            }
            else {
                reportNumberText = currencySymbol + Math.round(n);
            }
        } //Logic for numbers in thousands
        else if (Math.round(Math.abs(n) / 1000) * 1000 < 1000000) {
            var num_temp_cal = Math.round(Math.abs(n)/ 1000) * 1000;
            if (n < 0) {
                reportNumberText = currencySymbol + "(" + num_temp_cal.toLocaleString("en-US") + ")";
            }
            else {
                reportNumberText = currencySymbol + num_temp_cal.toLocaleString("en-US");
            }
            
        } //Logic for large nuumbers
        else {
            console.log("Largest<Million,Billion,Trillion)");
            var n_org = n;
            //Get the non-decimal part of number
            n = String(Math.abs(parseFloat(n.split(".")[0]))).split(".")[0];
            //Number of decimal places to retain
            var number_of_decimal_retain = 2;
            var type_curr = "";

            //Million Calculation
            if (n.length < 10) {

            //Where the decimal point will be inserted
            var insert_period_at = n.length - 6;
            var number_of_millions = String(n).slice(0, insert_period_at) + "." + String(n).slice(insert_period_at, insert_period_at + number_of_decimal_retain);
            type_curr = "million";
            var rounded_number=0
            if(n.length==7){ //less than 10 million retain 2 decimal places
                rounded_number = (number_of_millions*100)/100
            }else{
                rounded_number = Number(Number(number_of_millions).toFixed(1));
            }
            reportNumberText = String(rounded_number);
            }
            //Billion Calculation
            else if (n.length < 13) {
            insert_period_at = n.length - 9; //Where to insert decimal point
            var number_of_billions = String(n).slice(0, insert_period_at) + "." + String(n).slice(insert_period_at, insert_period_at + number_of_decimal_retain);
            type_curr = "billion";
            var rounded_number=0
            if(n.length==10){ //less than 10 billion keep 2 decimal places
                rounded_number = (number_of_billions*100)/100
            }else{
                rounded_number = Number(Number(number_of_billions).toFixed(1));
            }
            reportNumberText = String(rounded_number);
            //Trillion Calculation
            }
            else {
            insert_period_at = n.length - 12;
            var number_of_trillion = String(n).slice(0, insert_period_at) + "." + String(n).slice(insert_period_at, insert_period_at + number_of_decimal_retain);
            type_curr = "trillion";
            var rounded_number=0
            if(n.length==13){ //less than 10 trillion
                rounded_number = (number_of_trillion*100)/100
            }else{
                rounded_number = Number(Number(number_of_trillion).toFixed(1));
            }
            //Add commas to the number
            reportNumberText = String(rounded_number.toLocaleString("en-US"));
             }
            //formatting the numbers with currencySymbol and currency.  
            if (parseFloat(n_org) < 0) {
                reportNumberText = currencySymbol + "(" + reportNumberText + ") " + type_curr;
            }
            else {
                reportNumberText = currencySymbol + reportNumberText + " " + type_curr;
            }
        }
    return reportNumberText;
    } catch (error) {
        console.log('Error: ' + error.message);
        console.log(error);
        console.log(error.stack);
        return '!ERROR';

    }
}
