public class LoanBoardingUtility {

     public static LoanBoardingRequestWrapper.MscInfoDetails initializeMscInfoDetails() 
     {
        LoanBoardingRequestWrapper.MscInfoDetails mscInfoObj = new LoanBoardingRequestWrapper.MscInfoDetails();
        mscInfoObj.mscdetails28 = ''; 
        mscInfoObj.mscdetails27 = ''; 
        mscInfoObj.mscdetails26 = ''; 
        mscInfoObj.mscdetails25 = ''; 
        mscInfoObj.mscdetails29 = ''; 
        mscInfoObj.mscdetails20 = ''; 
        mscInfoObj.mscdetails24 = ''; 
        mscInfoObj.mscdetails23 = ''; 
        mscInfoObj.mscdetails22 = ''; 
        mscInfoObj.mscdetails21 = ''; 
        mscInfoObj.mscdetails17 = ''; 
        mscInfoObj.mscdetails16 = ''; 
        mscInfoObj.mscdetails15 = ''; 
        mscInfoObj.mscdetails14 = ''; 
        mscInfoObj.mscdetails19 = ''; 
        mscInfoObj.mscdetails18 = ''; 
        mscInfoObj.mscdetails7 = ''; 
        mscInfoObj.mscdetails30 = ''; 
        mscInfoObj.mscdetails8 = ''; 
        mscInfoObj.mscdetails5 = ''; 
        mscInfoObj.mscdetails6 = ''; 
        mscInfoObj.mscdetails13 = ''; 
        mscInfoObj.mscdetails12 = ''; 
        mscInfoObj.mscdetails11 = ''; 
        mscInfoObj.mscdetails9 = ''; 
        mscInfoObj.mscdetails10 =''; 
        mscInfoObj.mscdetails3 = ''; 
        mscInfoObj.mscdetails4 = ''; 
        mscInfoObj.mscdetails1 = ''; 
        mscInfoObj.mscdetails2 = '';  
        
        return mscInfoObj;
    }

    public static LoanBoardingRequestWrapper.BussinessVerification populateBusinessVerification() {
        LoanBoardingRequestWrapper.BussinessVerification busVer = new LoanBoardingRequestWrapper.BussinessVerification();
        busVer.productsBrandsCarried = ''; 
        busVer.businessName = ''; 
        busVer.managementAge = ''; 
        busVer.signatoryJobTitle = ''; 
        busVer.registered = ''; 
        busVer.salesFigure = ''; 
        busVer.warehouseLoaction = ''; 
        busVer.negative = ''; 
        busVer.natureOfBusi = ''; 
        busVer.managementPosition = ''; 
        busVer.noOfRegularEmp = ''; 
        busVer.busiType = ''; 
        busVer.signatoryName = ''; 
        busVer.businessAddress = ''; 
        busVer.phoneExt = ''; 
        busVer.managementName = ''; 
        busVer.creditReferencesName = ''; 
        busVer.citizenship = ''; 
        busVer.operatingExpenses = ''; 
        busVer.lengthOfBusinessExis = ''; 
        busVer.percentOwnership = ''; 
        busVer.applicantName = ''; 
        busVer.positive = ''; 
        busVer.rentMortAmt = ''; 
        busVer.branches = ''; 
        busVer.warehouse = ''; 
        busVer.creditReferencesAddress = ''; 
        busVer.creditReferencePhone = ''; 
        busVer.noOfCustomerDay = ''; 
        busVer.registeredName = ''; 
        busVer.othPropOwned = ''; 
        busVer.location = ''; 
        busVer.businessPhone = ''; 
        busVer.businessPremisesOwner = ''; 
        busVer.age = ''; 
        busVer.remarks = ''; 
        
        return busVer;
    }
    
    public static List<LoanBoardingRequestWrapper.LiabilityDetails> populateLiabilityDetails(Applicant__c app, Map<Id, List<BureauRespDtl__c>> appBureauMapByApplicant, Map<Integer, String> monthMap,Map<String,Map<String,String>> masterDataMap) {
        List<LoanBoardingRequestWrapper.LiabilityDetails> listLiabDtls = new List<LoanBoardingRequestWrapper.LiabilityDetails>();
        //System.debug('applicant id for Liability details: ' + app.Id);
        
        List<BureauRespDtl__c> listForBureauRes = appBureauMapByApplicant.get(app.Id);
        if (listForBureauRes != null && !listForBureauRes.isEmpty()) {
            for (BureauRespDtl__c eachBurresObj : listForBureauRes) {
                
                if(eachBurresObj.Source__c!=null && eachBurresObj.Source__c =='Manual'){
                    if(eachBurresObj.LoanApplication__r.Add_Another_Loan__c!=null && eachBurresObj.LoanApplication__r.Add_Another_Loan__c =='Yes'){
                        LoanBoardingRequestWrapper.LiabilityDetails liabDetail = new LoanBoardingRequestWrapper.LiabilityDetails();
                        liabDetail.EMIsToBePaid = (eachBurresObj.NoEMIPaid__c !=null && eachBurresObj.Tenure__c !=null ) ? String.valueOf(Integer.valueOf(eachBurresObj.Tenure__c) - Integer.valueOf(eachBurresObj.NoEMIPaid__c)) : '0';
                        liabDetail.considerForIncome = '';//eachBurresObj.ConsiderObligation__c != null ? eachBurresObj.ConsiderObligation__c : ''; 
                        liabDetail.totalOutstanding = ''; //Need to be mapped by finnone
                        liabDetail.liabilityTypeOfLoan = masterDataMap.get('Nature Of Loan') !=null && eachBurresObj.NatureOfLoan__c !=null ? (masterDataMap.get('Nature Of Loan').get(eachBurresObj.NatureOfLoan__c) !=null ? masterDataMap.get('Nature Of Loan').get(eachBurresObj.NatureOfLoan__c) : '') :'' ;   
                        liabDetail.liabiltiyStatusType = ''; 
                         
                        liabDetail.loanOwnership = app.FullName__c!=null?app.FullName__c.left(30):''; //eachBurresObj.LoanName__c != null ? String.valueOf(eachBurresObj.LoanName__c).left(30)  : ''; 
                        liabDetail.noOfYearsExistFinancier = ''; 
                        liabDetail.noOfBounces = eachBurresObj.TotalBouncesInRTR__c !=null ? String.valueOf(eachBurresObj.TotalBouncesInRTR__c) : ''; 
                        liabDetail.liabilitySource = eachBurresObj.Source__c != null ? eachBurresObj.Source__c : ''; 
                        liabDetail.liabilityEmiAmount = String.valueOf(eachBurresObj.EMI__c) != null ? String.valueOf(eachBurresObj.EMI__c) : ''; 
                        liabDetail.noOfInstallments = ''; 
                        liabDetail.obligationToBeDeducted = ''; 

                        if(eachBurresObj.Treatment__c !=null && eachBurresObj.Treatment__c=='To continue - Obligate'){
                            liabDetail.considerForFOIR = 'Y';
                        }else{
                            liabDetail.considerForFOIR = 'N';
                        }

                        if(eachBurresObj.Treatment__c !=null && eachBurresObj.Treatment__c=='BT loan'){
                            liabDetail.considerForBT = 'Y';
                        }else{
                            liabDetail.considerForBT = 'N';
                        }
                        


                        liabDetail.liabilityNoOfEmi = '';//eachBurresObj.Tenure__c!=null ? eachBurresObj.Tenure__c: ''; 
                        liabDetail.fdAsCollateral = ''; 
                        liabDetail.outwardChequeRet = ''; 
                        liabDetail.loanClosureDate = '';// No need to Map //eachBurresObj.CloseDate__c != null ? String.valueOf(eachBurresObj.CloseDate__c.day()) + '-' + monthMap.get(eachBurresObj.CloseDate__c.month()) + '-' + String.valueOf(eachBurresObj.CloseDate__c.year()) : '';
                        liabDetail.existingFinanciarname = ''; 
                        liabDetail.loanAmount = String.valueOf(eachBurresObj.LoanAmount__c) != null ? String.valueOf(eachBurresObj.LoanAmount__c) : ''; 
                        liabDetail.financierName = eachBurresObj.FinancierName__c != null ? eachBurresObj.FinancierName__c : ''; 
                        liabDetail.installmentsToBePaid = String.valueOf(eachBurresObj.NoEMIPaid__c) != null ? String.valueOf(eachBurresObj.NoEMIPaid__c) : ''; 
                        liabDetail.loanAccountNumber = ''; 
                        liabDetail.existingNoOfBounces = ''; 
                        liabDetail.bankStatementCollected = ''; 
                        liabDetail.emiAlreadyPaid = String.valueOf(eachBurresObj.NoEMIPaid__c) != null ? String.valueOf(eachBurresObj.NoEMIPaid__c) : ''; 
                        liabDetail.considerForObligation = eachBurresObj.ConsiderObligation__c != null ? eachBurresObj.ConsiderObligation__c : '';
                        liabDetail.totalNoOfEMIs = eachBurresObj.Tenure__c!=null ? String.valueOf(eachBurresObj.Tenure__c) : ''; 
                        liabDetail.princOutstanding = String.valueOf(eachBurresObj.CurrentOs__c) != null ? String.valueOf(eachBurresObj.CurrentOs__c) : ''; 
                        
                        // adding values
                        listLiabDtls.add(liabDetail);
                    }
                }
                else
                {
                    LoanBoardingRequestWrapper.LiabilityDetails liabDetail = new LoanBoardingRequestWrapper.LiabilityDetails();
                    liabDetail.considerForIncome = ''; // Pass as Blank eachBurresObj.ConsiderObligation__c != null ? eachBurresObj.ConsiderObligation__c : ''; 
                    liabDetail.totalOutstanding = ''; 
                    liabDetail.liabilityTypeOfLoan = masterDataMap.get('Nature Of Loan') !=null && eachBurresObj.NatureOfLoan__c !=null ? (masterDataMap.get('Nature Of Loan').get(eachBurresObj.NatureOfLoan__c) !=null ? masterDataMap.get('Nature Of Loan').get(eachBurresObj.NatureOfLoan__c) : '') :'' ;   
                    liabDetail.liabiltiyStatusType = ''; 
                    liabDetail.loanOwnership = app.FullName__c!=null?app.FullName__c.left(30):'';  //eachBurresObj.LoanName__c != null ? String.valueOf(eachBurresObj.LoanName__c).left(30): ''; 
                    liabDetail.noOfYearsExistFinancier = ''; 
                    liabDetail.noOfBounces = eachBurresObj.TotalBouncesInRTR__c !=null ? String.valueOf(eachBurresObj.TotalBouncesInRTR__c) : '';  
                    liabDetail.liabilitySource = eachBurresObj.Source__c != null ? eachBurresObj.Source__c : ''; 
                    liabDetail.liabilityEmiAmount = String.valueOf(eachBurresObj.EMI__c) != null ? String.valueOf(eachBurresObj.EMI__c) : ''; 
                    liabDetail.noOfInstallments = ''; 
                    liabDetail.obligationToBeDeducted = ''; 
                    
                    
                    if(eachBurresObj.Treatment__c !=null && eachBurresObj.Treatment__c=='To continue - Obligate'){
                        liabDetail.considerForFOIR = 'Y';
                    }else{
                        liabDetail.considerForFOIR = 'N';
                    }

                    if(eachBurresObj.Treatment__c !=null && eachBurresObj.Treatment__c=='BT loan'){
                        liabDetail.considerForBT = 'Y';
                    }else{
                        liabDetail.considerForBT = 'N';
                    }



                    liabDetail.liabilityNoOfEmi = '';  // No need to paas eachBurresObj.Tenure__c!=null ? eachBurresObj.Tenure__c: ''; 
                    liabDetail.fdAsCollateral = ''; 
                    liabDetail.outwardChequeRet = ''; 
                    liabDetail.loanClosureDate = '';//eachBurresObj.CloseDate__c != null ? String.valueOf(eachBurresObj.CloseDate__c.day()) + '-' + monthMap.get(eachBurresObj.CloseDate__c.month()) + '-' + String.valueOf(eachBurresObj.CloseDate__c.year()) : '';
                    liabDetail.existingFinanciarname = ''; 
                    liabDetail.loanAmount = String.valueOf(eachBurresObj.LoanAmount__c) != null ? String.valueOf(eachBurresObj.LoanAmount__c) : ''; 
                    liabDetail.financierName = eachBurresObj.FinancierName__c != null ? eachBurresObj.FinancierName__c : ''; 
                    liabDetail.installmentsToBePaid = String.valueOf(eachBurresObj.NoEMIPaid__c) != null ? String.valueOf(eachBurresObj.NoEMIPaid__c) : ''; 
                    liabDetail.loanAccountNumber = ''; 
                    liabDetail.existingNoOfBounces = ''; 
                    liabDetail.bankStatementCollected = ''; 
                    liabDetail.emiAlreadyPaid = String.valueOf(eachBurresObj.NoEMIPaid__c) != null ? String.valueOf(eachBurresObj.NoEMIPaid__c) : ''; 
                    liabDetail.considerForObligation = eachBurresObj.ConsiderObligation__c != null ? eachBurresObj.ConsiderObligation__c : '';
                    liabDetail.totalNoOfEMIs = eachBurresObj.Tenure__c!=null ? String.valueOf(eachBurresObj.Tenure__c) : ''; 
                    liabDetail.princOutstanding = String.valueOf(eachBurresObj.CurrentOs__c) != null ? String.valueOf(eachBurresObj.CurrentOs__c) : ''; 
                    
                    // adding values
                    listLiabDtls.add(liabDetail);
                }
            }
        }
        return listLiabDtls;
    }

    public static List<LoanBoardingRequestWrapper.AddressDetails> populatePropertyDetails(
        Applicant__c app,
        Map<Id, List<ApplAddr__c>> appAddMap,
        Map<String, LocMstr__c> mapLocMas,
        Map<String, Map<String, String>> masterDataMap
    ) {
        List<LoanBoardingRequestWrapper.AddressDetails> listAddDetails = new List<LoanBoardingRequestWrapper.AddressDetails>();
        List<ApplAddr__c> listOfAddsAppl = appAddMap.get(app.Id);
        
        if (listOfAddsAppl != null && !listOfAddsAppl.isEmpty()) {
            for (ApplAddr__c eachAppAddr : listOfAddsAppl) {
                LocMstr__c locdata = mapLocMas!=null ? mapLocMas.get(eachAppAddr.City__c) :null;
                LoanBoardingRequestWrapper.AddressDetails addDetails = new LoanBoardingRequestWrapper.AddressDetails();
                addDetails.country = '1'; // Hardcoded
                addDetails.extension = '';
                addDetails.city = (locdata != null) ? (locdata.CityId__c != null ? String.valueOf(locdata.CityId__c) : '') : '';
                System.debug('addDetails.city:'+addDetails.city );
                addDetails.smsFlag = '';
                addDetails.phone2 = '';
                addDetails.emailId = app.EmailId__c != null ? String.valueOf(app.EmailId__c) : '';
                addDetails.phone1 = '';
                addDetails.poBox = '';
                addDetails.propertyStatus = eachAppAddr.OwnType__c != null ? eachAppAddr.OwnType__c : '';
                addDetails.inactive = '';
                addDetails.addressLine1 = ((eachAppAddr.HouseNo__c != null ? String.valueOf(eachAppAddr.HouseNo__c) + ' ' : '') + (eachAppAddr.AddrLine1__c != null ? String.valueOf(eachAppAddr.AddrLine1__c) : '')).left(120);
                addDetails.addressLine2 = eachAppAddr.AddrLine2__c != null ? String.valueOf(eachAppAddr.AddrLine2__c).left(120) : '';
                addDetails.addressLine3 = eachAppAddr.Landmark__c != null ? eachAppAddr.Landmark__c : '';
                addDetails.state = (locdata != null) ? (locdata.StateId__c != null ? String.valueOf(locdata.StateId__c) : '') : '';
                addDetails.fax = '';
                addDetails.landmark = ''; // Hardcoded to empty
                addDetails.mailingAddressFlag = eachAppAddr.MailAddr__c ? 'Y' : 'N';
                addDetails.inactiveAddress = '';
                addDetails.copyaddress = '';
                addDetails.stayDurationCityYear = eachAppAddr.StabAtAddressYr__c != null ? String.valueOf(eachAppAddr.StabAtAddressYr__c) : '';
                addDetails.smsMobileSecondary = '';
                addDetails.addressType = masterDataMap !=null ? masterDataMap.get('Address Type') != null ? (masterDataMap.get('Address Type').get(eachAppAddr.AddrTyp__c) != null ? masterDataMap.get('Address Type').get(eachAppAddr.AddrTyp__c) : '') : '' :'';
                addDetails.mobile = app.MobNumber__c != null ? app.MobNumber__c : '';
                addDetails.stayDurationCityMon = eachAppAddr.StabAtAddressMnth__c !=null ? String.valueOf(eachAppAddr.StabAtAddressMnth__c) : '';
                addDetails.stayDurationCurrAddressYr = eachAppAddr.StabAtAddressYr__c != null ? String.valueOf(eachAppAddr.StabAtAddressYr__c) : '';
                addDetails.areaCode = (locdata != null) ? (locdata.CityId__c != null ? String.valueOf(locdata.CityId__c) : '') : '';
                addDetails.district = '';
                addDetails.pinCode = eachAppAddr.Pincode__c != null ? eachAppAddr.Pincode__c : '';
                addDetails.smsMobilePrimary = '';
                addDetails.stayDurationCurrAddressMon = eachAppAddr.StabAtAddressMnth__c !=null ? String.valueOf(eachAppAddr.StabAtAddressMnth__c) : '';
                listAddDetails.add(addDetails);
            }
        }
        
        return listAddDetails;
    }

    public static List<LoanBoardingRequestWrapper.RateRiskDetails> createBlankRateRiskDetails() {
        List<LoanBoardingRequestWrapper.RateRiskDetails> listRateRiskDetails = new List<LoanBoardingRequestWrapper.RateRiskDetails>();
        LoanBoardingRequestWrapper.RateRiskDetails rateRiskDet = new LoanBoardingRequestWrapper.RateRiskDetails();
        rateRiskDet.commissionRate = ''; 
        rateRiskDet.lessorName = ''; 
        rateRiskDet.bpType = ''; 
        rateRiskDet.consortiumType = ''; 
        rateRiskDet.contributionRate = ''; 
        rateRiskDet.contributionAmt = ''; 
        listRateRiskDetails.add(rateRiskDet);
        return listRateRiskDetails;
    }

     // Helper method to compute max and min values from a list of balances
    public static Map<String, Decimal> computeOverallMaxMin(Decimal[] balances) {
        if(balances!=null && balances.size()>1){
            
            Decimal maxValue =  balances[0] ;
            Decimal minValue =   balances[0] ;
            
            for (Decimal balance : balances) {
                if (balance != null) {
                    if (maxValue == null || balance > maxValue) {
                        maxValue = balance;
                    }
                    if (minValue == null || balance < minValue) {
                        minValue = balance;
                    }
                }
            }
            
            Map<String, Decimal> result = new Map<String, Decimal>();
            return result;
        }
        else{
            return null;
        }
    }

    public static LoanBoardingRequestWrapper.GSTInfoDetails populateGSTDetails(ApplicantEmployment__c finalAppEmpObj,ApplAddr__c finalAddress,ApplGST__c finalGSTObj ,LocMstr__c  locdataGst , LocMstr__c locdataGstForgstOnly,String addressTypeGst ) {
        LoanBoardingRequestWrapper.GSTInfoDetails gstInDetails =new LoanBoardingRequestWrapper.GSTInfoDetails();
        if(finalAppEmpObj != null) {
            if(finalAppEmpObj.GST_Registered__c != null && finalAppEmpObj.GST_Registered__c.equalsIgnoreCase('Yes')) {
                
                
                if(finalGSTObj.LastSelectedAddrType__c == 'GST Address') {
                    gstInDetails.gstAddress = 'OTHERS';
                    gstInDetails.gstPinCode = finalGSTObj.Pincode__c != null ? finalGSTObj.Pincode__c : '';
                    gstInDetails.gstAddressLine1 = ((finalGSTObj.HouseNo__c != null ? String.valueOf(finalGSTObj.HouseNo__c) + ' ' : '') + (finalGSTObj.AddrLine1__c != null ? String.valueOf(finalGSTObj.AddrLine1__c) : '')).left(120);
                    gstInDetails.gstAddressLine2 = finalGSTObj.AddrLine2__c != null ? String.valueOf(finalGSTObj.AddrLine2__c).left(120) : '';
                    gstInDetails.gstAddressLine3 = finalGSTObj.Landmark__c != null ? finalGSTObj.Landmark__c : '';
                    gstInDetails.gstCity = locdataGstForgstOnly != null ? String.valueOf(locdataGstForgstOnly.CityId__c) : '';
                    gstInDetails.gstState = locdataGstForgstOnly != null ? String.valueOf(locdataGstForgstOnly.StateGSTId__c) : '';  
                } else {
                    gstInDetails.gstAddress = addressTypeGst;
                    gstInDetails.gstPinCode = (finalAddress != null && finalAddress.Pincode__c != null) ? finalAddress.Pincode__c : '';  
                    
                    if(finalAddress != null && finalAddress.AddrTyp__c == 'Principal place for business') {
                        gstInDetails.gstAddressLine1 = ((finalAddress.HouseNo__c != null ? String.valueOf(finalAddress.HouseNo__c) + ' ' : '') + (finalAddress.AddrLine1__c != null ? String.valueOf(finalAddress.AddrLine1__c) : '')).left(120);                                        
                        gstInDetails.gstAddressLine2 = finalAddress.AddrLine2__c != null ? String.valueOf(finalAddress.AddrLine2__c).left(120) : ''; 
                        gstInDetails.gstAddressLine3 = finalAddress.Landmark__c != null ? finalAddress.Landmark__c : '';
                    } else if(finalAddress != null && finalAddress.AddrTyp__c == 'Residence Cum office') {
                        gstInDetails.gstAddressLine1 = ((finalAddress.HouseNo__c != null ? String.valueOf(finalAddress.HouseNo__c) + ' ' : '') + (finalAddress.AddrLine1__c != null ? String.valueOf(finalAddress.AddrLine1__c) : '')).left(120);                                        
                        gstInDetails.gstAddressLine2 = finalAddress.AddrLine2__c != null ? String.valueOf(finalAddress.AddrLine2__c).left(120) : ''; 
                        gstInDetails.gstAddressLine3 = finalAddress.Landmark__c != null ? finalAddress.Landmark__c : '';
                    } else {
                        gstInDetails.gstAddressLine1 = '';
                        gstInDetails.gstAddressLine2 = ''; 
                        gstInDetails.gstAddressLine3 = (finalAddress != null && finalAddress.Landmark__c != null) ? finalAddress.Landmark__c : '';
                    }
                    gstInDetails.gstCity = locdataGst != null ? String.valueOf(locdataGst.CityId__c) : '';   
                    gstInDetails.gstState = locdataGst != null ? String.valueOf(locdataGst.StateGSTId__c) : '';      
                }
                
                gstInDetails.gstReqd = 'Y'; 
                gstInDetails.gstCustomerName = (finalGSTObj != null && finalGSTObj.Applicant__r.UCID__c != null) ? String.valueOf(finalGSTObj.Applicant__r.UCID__c).left(8) : '';
                gstInDetails.gstCountry = '1'; 
                gstInDetails.gstNumber = finalGSTObj != null ? String.valueOf(finalGSTObj.GSTIN__c) : '';
                gstInDetails.gstApplicantType = 'C'; 
                gstInDetails.gstCustomerType = (finalGSTObj != null && finalGSTObj.Applicant__r.ApplType__c != null) ? finalGSTObj.Applicant__r.ApplType__c : '';  
            } else {
                gstInDetails.gstReqd = 'N'; 
                gstInDetails.gstCustomerName = '';
                gstInDetails.gstCountry = ''; 
                gstInDetails.gstAddress = ''; 
                gstInDetails.gstAddressLine3 = ''; 
                gstInDetails.gstAddressLine2 = ''; 
                gstInDetails.gstNumber = ''; 
                gstInDetails.gstAddressLine1 = ''; 
                gstInDetails.gstCity = ''; 
                gstInDetails.gstState = ''; 
                gstInDetails.gstPinCode = ''; 
                gstInDetails.gstApplicantType = ''; 
                gstInDetails.gstCustomerType = '';
            }
        } else {
            gstInDetails.gstReqd = 'N'; 
            gstInDetails.gstCustomerName = '';
            gstInDetails.gstCountry = ''; 
            gstInDetails.gstAddress = ''; 
            gstInDetails.gstAddressLine3 = ''; 
            gstInDetails.gstAddressLine2 = ''; 
            gstInDetails.gstNumber = ''; 
            gstInDetails.gstAddressLine1 = ''; 
            gstInDetails.gstCity = ''; 
            gstInDetails.gstState = ''; 
            gstInDetails.gstPinCode = ''; 
            gstInDetails.gstApplicantType = ''; 
            gstInDetails.gstCustomerType = '';
        }
        return gstInDetails;
        
        
    }

    public static List<LoanBoardingRequestWrapper.InitialMoneyDepositDetails> createInitialMoneyDepositDetails(List<ApplIMD__c> listForImdDetails) {
        List<LoanBoardingRequestWrapper.InitialMoneyDepositDetails> listIniMoneyDetails = new List<LoanBoardingRequestWrapper.InitialMoneyDepositDetails>();
        
        if(listForImdDetails !=null && !listForImdDetails.isEMpty())
        {
            for(ApplIMD__c eachAppImd1 : listForImdDetails )
            {
                LoanBoardingRequestWrapper.InitialMoneyDepositDetails iniMoneyDepDetail=new LoanBoardingRequestWrapper.InitialMoneyDepositDetails();    
                
                iniMoneyDepDetail.imdStatus =''; 
                iniMoneyDepDetail.imdCity = eachAppImd1.City__c !=null ? String.valueOf(eachAppImd1.City__c) : ''; 
                iniMoneyDepDetail.imdChequeDate =''; 
                iniMoneyDepDetail.imdChqNo =''; 
                iniMoneyDepDetail.imdCurrency =''; //blank
                iniMoneyDepDetail.imdPaidOn =''; //blank
                iniMoneyDepDetail.imdDealingBank =''; 
                iniMoneyDepDetail.imdFTMode =''; //blank
                iniMoneyDepDetail.imdHostAccNo ='';//blank 
                iniMoneyDepDetail.imdAccNo =''; //blank
                iniMoneyDepDetail.imdIncomeTaxIdType ='';//blank 
                iniMoneyDepDetail.imdHoldAccBankName =''; //blank
                iniMoneyDepDetail.imdHoldUnhold =''; //blank
                iniMoneyDepDetail.imdHoldAccountNo =''; //blank
                iniMoneyDepDetail.imdPaymentMode =''; //blank
                iniMoneyDepDetail.imdCmsCode =''; //blank
                iniMoneyDepDetail.imdIncomeTaxIdNo =''; //blank
                iniMoneyDepDetail.imdTdsByCustomer =''; //blank
                iniMoneyDepDetail.ifscCode =''; //blank
                iniMoneyDepDetail.imdInFavourOf =''; 
                iniMoneyDepDetail.imdDepositSlipNo =''; //blank
                iniMoneyDepDetail.imdCMSNumeric =''; //blank
                iniMoneyDepDetail.imdSolId =''; //blank
                iniMoneyDepDetail.imdUTRNo =eachAppImd1.PaymentRefNo__c !=null ? eachAppImd1.PaymentRefNo__c : ''; //blank   //ApplIMD__c =>PaymentRefNo__c 
                iniMoneyDepDetail.imdTranDae =''; //blank
                iniMoneyDepDetail.imdReason =''; //blank
                iniMoneyDepDetail.imdCustomerId =''; //blank
                iniMoneyDepDetail.imdChequeId =''; 
                iniMoneyDepDetail.imdMicrCode =''; //blank
                iniMoneyDepDetail.imdReceiptNo =''; //blank
                iniMoneyDepDetail.imdDepositSlipAmt =''; //blank
                iniMoneyDepDetail.imdHoldAccBankBranch =''; //blank
                iniMoneyDepDetail.imdAmount = eachAppImd1.InstrumentAmt__c !=null ? String.valueOf(eachAppImd1.InstrumentAmt__c) :'';
                //eachAppImd1.IMDAmt__c !=null ? String.valueOf(eachAppImd1.IMDAmt__c) : '' ; // eachAppImd1.IMDAmt__c ? eachAppImd1.IMDAmt__c : '' ; 
                iniMoneyDepDetail.imdBankBranch =''; //blank
                iniMoneyDepDetail.imdDepositSlipType =''; //blank
                iniMoneyDepDetail.imdDrawnOn =''; 
                iniMoneyDepDetail.imdHoldAccount =''; //blank
                
                listIniMoneyDetails.add(iniMoneyDepDetail);
            }
        }
        return listIniMoneyDetails;
    }

    Public static List<Ref__c> getAllReference(List<Ref__c> refList){
        Map<Id,List<Ref__c>> applicanttoRefMap = new Map<Id,List<Ref__c>>();
        
        for(Ref__c ref: refList){
            if(applicanttoRefMap.containsKey(ref.Applicant__c) ){
                if(applicanttoRefMap.get(ref.Applicant__c).size()<2){
                    applicanttoRefMap.get(ref.Applicant__c).add(ref);
                }
                
            }else{
                applicanttoRefMap.put(ref.Applicant__c,new List<Ref__c>{ref});
            }
        }
        List<Ref__c> refList1 = new List<Ref__c>();
        for(String applicantId : applicanttoRefMap.keySet()){
            refList1.addAll(applicanttoRefMap.get(applicantId));
        }
        return refList1;
    }

 
    public static List<LoanBoardingRequestWrapper.SplitDisbursalDetails> processDisbursements(
        List<Disbursement__c> listDisbNSplitDis,
        Map<String, Map<String, String>> masterDataMap,
        Map<String, LocMstr__c> mapLocMas,
        Map<Integer, String> monthMap
    ) {
        List<LoanBoardingRequestWrapper.SplitDisbursalDetails> allSplitDisbursalDetails = new List<LoanBoardingRequestWrapper.SplitDisbursalDetails>();
        
        for (Disbursement__c eachDisb : listDisbNSplitDis) {
            List<LoanBoardingRequestWrapper.SplitDisbursalDetails> splitDetails = processEachDisbursement(eachDisb, masterDataMap, mapLocMas, monthMap);
            allSplitDisbursalDetails.addAll(splitDetails);
        }
        
        return allSplitDisbursalDetails;
    }

    private static List<LoanBoardingRequestWrapper.SplitDisbursalDetails> processEachDisbursement(
        Disbursement__c eachDisb,
        Map<String, Map<String, String>> masterDataMap,
        Map<String, LocMstr__c> mapLocMas,
        Map<Integer, String> monthMap
    ) {
        List<LoanBoardingRequestWrapper.SplitDisbursalDetails> listSplitDis = new List<LoanBoardingRequestWrapper.SplitDisbursalDetails>();
        
        for (Split_Disbur__c eachSplitDisObj : eachDisb.Split_Disbursements__r) {
            LoanBoardingRequestWrapper.SplitDisbursalDetails spDisDetail = new LoanBoardingRequestWrapper.SplitDisbursalDetails();

            if (System.Label.Disbursal_Date_Condition != null && System.Label.Disbursal_Date_Condition == 'Y') {
                spDisDetail.disbursalDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());
            } else {
                spDisDetail.disbursalDate = System.Label.DisbDateLoanBoarding;
            }

            spDisDetail.paymentMode = masterDataMap.get('Payment Mode') != null && eachSplitDisObj.Pay_Mode__c != null
                ? (masterDataMap.get('Payment Mode').get(eachSplitDisObj.Pay_Mode__c.toupperCase()) != null
                    ? masterDataMap.get('Payment Mode').get(eachSplitDisObj.Pay_Mode__c.toupperCase())
                    : '')
                : '';

            if ((eachSplitDisObj.Fund_Transf_Mode__c) != null) {
                spDisDetail.ftMode = masterDataMap.get('Fund Transfer Mode') != null && eachSplitDisObj.Fund_Transf_Mode__c != null
                    ? (masterDataMap.get('Fund Transfer Mode').get(eachSplitDisObj.Fund_Transf_Mode__c.toupperCase()) != null
                        ? masterDataMap.get('Fund Transfer Mode').get(eachSplitDisObj.Fund_Transf_Mode__c.toupperCase())
                        : '')
                    : '';
            } else {
                spDisDetail.ftMode = '';
            }

            spDisDetail.chequeNo = eachSplitDisObj.Cheq_DD_No__c != null ? eachSplitDisObj.Cheq_DD_No__c : '0'; // Hardcoded

            if (eachSplitDisObj.Payable_At__c != null) {
                spDisDetail.payableAt = mapLocMas.get(String.valueOf(eachSplitDisObj.Payable_At__c).toUppercase()) != null
                    ? mapLocMas.get(String.valueOf(eachSplitDisObj.Payable_At__c).toUppercase()).CityId__c != null
                        ? mapLocMas.get(String.valueOf(eachSplitDisObj.Payable_At__c).toUppercase()).CityId__c
                        : ''
                    : '';
            } else {
                spDisDetail.payableAt = '';
            }

            spDisDetail.inFavourOf = eachSplitDisObj.Cheq_Favor_Dets__c != null ? eachSplitDisObj.Cheq_Favor_Dets__c : '';
            spDisDetail.disbTo = 'LS'; // OK Hardcoded
            spDisDetail.effectIRR = '';
            spDisDetail.chequeDate = eachSplitDisObj.Cheq_DD_Date__c != null
                ? String.valueOf(eachSplitDisObj.Cheq_DD_Date__c.day()) + '-' + monthMap.get(eachSplitDisObj.Cheq_DD_Date__c.month()) + '-' + String.valueOf(eachSplitDisObj.Cheq_DD_Date__c.year())
                : '';
            spDisDetail.splitRemarks = eachSplitDisObj.Remarks__c != null ? eachSplitDisObj.Remarks__c : '';
            spDisDetail.principalStartDate = eachDisb.Princ_Start_Date__c != null
                ? String.valueOf(eachDisb.Princ_Start_Date__c.day()) + '-' + monthMap.get(eachDisb.Princ_Start_Date__c.month()) + '-' + String.valueOf(eachDisb.Princ_Start_Date__c.year())
                : '';
            spDisDetail.splitAccountNo = eachSplitDisObj.Cheq_Favor_Acc_No__c != null ? eachSplitDisObj.Cheq_Favor_Acc_No__c : '';
            spDisDetail.bpName = 'LS'; // Hardcoded OK
            spDisDetail.cashBankAccount = masterDataMap.get('CashBank Account') != null
                ? masterDataMap.get('CashBank Account').get(eachSplitDisObj.Fedbank_Acc_Nm__c) != null
                    ? String.valueOf(masterDataMap.get('CashBank Account').get(eachSplitDisObj.Fedbank_Acc_Nm__c))
                    : ''
                : '';
            spDisDetail.disbursementTo = ''; // Blank
            spDisDetail.splitAccNo = eachSplitDisObj.Cheq_Favor_Acc_No__c != null ? eachSplitDisObj.Cheq_Favor_Acc_No__c : '';
            spDisDetail.splitAmount = String.valueOf(eachSplitDisObj.Split_Cheque_Amt__c) != null ? String.valueOf(eachSplitDisObj.Split_Cheque_Amt__c) : '';

            if (eachDisb.Princ_Rec_on__c != null) {
                if (String.valueOf(eachDisb.Princ_Rec_on__c).equalsIgnoreCase('Amount Disbursed till Date')) {
                    spDisDetail.principalRecoveryOn = 'D';
                } else if (String.valueOf(eachDisb.Princ_Rec_on__c).equalsIgnoreCase('AMOUNT FINANCED')) {
                    spDisDetail.principalRecoveryOn = 'S';
                } else {
                    spDisDetail.principalRecoveryOn = '';
                }
            } else {
                spDisDetail.principalRecoveryOn = '';
            }

            spDisDetail.splitCreditPeriod = '0'; // OK
            spDisDetail.micrCode = '';

            if (eachSplitDisObj.Pay_Mode__c != null && eachSplitDisObj.Pay_Mode__c == 'Funds Transfer') {
                spDisDetail.ifscCode = eachSplitDisObj.IFSC_Detail__c != null ? eachSplitDisObj.IFSC_Detail__c : '';
            } else {
                spDisDetail.ifscCode = '';
            }

            // Hardcoded Effective Date as Today Date
            spDisDetail.effectiveDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());

            listSplitDis.add(spDisDetail);
        }

        return listSplitDis;
    }

    public static List<LoanBoardingRequestWrapper.StakeHolderDetails> createStakeHolderDetails() {
        List<LoanBoardingRequestWrapper.StakeHolderDetails> listStakDetls = new List<LoanBoardingRequestWrapper.StakeHolderDetails>();
        LoanBoardingRequestWrapper.StakeHolderDetails stkHolderDetails = new LoanBoardingRequestWrapper.StakeHolderDetails();
        
        stkHolderDetails.corpStakeholderTitle = ''; 
        stkHolderDetails.corpStakeholderStakePercent = ''; 
        stkHolderDetails.corpStakeholderContactType = ''; 
        stkHolderDetails.corpStakeholderDINNo = ''; 
        stkHolderDetails.corpStakeholderFirstName = ''; 
        stkHolderDetails.corpStakeholderDOI = ''; 
        stkHolderDetails.corpStakeholderIdNo = ''; 
        stkHolderDetails.corpStakeholderPassportNo = ''; 
        stkHolderDetails.corpStakeRelatedNameOfCompany = ''; 
        stkHolderDetails.corpStakeholderIdType = ''; 
        stkHolderDetails.corpStakeHolderPosition = ''; 
        stkHolderDetails.corpStakeholderLastName = ''; 
        stkHolderDetails.corpStakeholderGender = ''; 
        stkHolderDetails.corpStakeholderCompanyName = ''; 
        stkHolderDetails.corpStakeholderConsiderGrading = ''; 
        stkHolderDetails.corpStakeholderNationality = ''; 
        stkHolderDetails.corpStakeholderTIN = ''; 
        stkHolderDetails.corpStakeholderMidName = ''; 
        stkHolderDetails.corpStakeholderTotalExp = ''; 
        stkHolderDetails.corpStakeholderJoinedSince = ''; 
        stkHolderDetails.corpStakeHolderPhone = ''; 
        
        listStakDetls.add(stkHolderDetails);
        
        return listStakDetls;
    }


    public static LoanBoardingRequestWrapper.WorkDetailsSalaried createWorkDetailsSalaried(ApplicantEmployment__c appEm,Map<String,Industry__c> mapEmp,Map<String,Map<String,String>> masterDataMap) {
        LoanBoardingRequestWrapper.WorkDetailsSalaried wrkDetailSal = new LoanBoardingRequestWrapper.WorkDetailsSalaried();

        if (appEm != null) {
            wrkDetailSal.emplyementType = ''; // Blank
            wrkDetailSal.shareHolding = ''; // Blank
            wrkDetailSal.labourIdExpiryDate = ''; // Blank
            wrkDetailSal.pranNo = ''; // Blank
            wrkDetailSal.associatedSinceInception = ''; // Blank
            wrkDetailSal.indutsryWork = mapEmp !=null && appEm.IndustryType__r.Name!=null ? mapEmp.get(appEm.IndustryType__r.Name).IndustryID__c :  ''; // hardcoded appEm.IndustryType__r.Name !=null ?appEm.IndustryType__r.Name:''
            wrkDetailSal.mcaNumber = ''; // Blank
            wrkDetailSal.uanNumber = ''; // Not capturing
            wrkDetailSal.businessName = appEm.EntityName__c != null ? appEm.EntityName__c : '';
            wrkDetailSal.websiteAddress = '';
            wrkDetailSal.employerName = appEm.EmployerName__r.EmployerId__c != null ? appEm.EmployerName__r.EmployerId__c : '';
            wrkDetailSal.prevEmployerAddress = ''; // Blank
            wrkDetailSal.industryEmployment = appEm.IndustryType__r.IndustryID__c != null ? appEm.IndustryType__r.IndustryID__c : ''; // check this which one should take
            wrkDetailSal.employmentStatus = ''; // Blank
            wrkDetailSal.employeeNo = ''; // Blank
            wrkDetailSal.yearPreviousJobMon = ''; // Blank
            wrkDetailSal.lengthOfBusiness = String.valueOf(appEm.CurrentBusinessVintage_Months__c) != null ? String.valueOf(appEm.CurrentBusinessVintage_Months__c) : ''; // check this
            wrkDetailSal.yearPreviousJobYr = ''; // blank
            wrkDetailSal.subIndEmplyment = ''; // appEm.SubIndustry__r.SubIndustryID__c !=null ?appEm.SubIndustry__r.SubIndustryID__c :''; // appEm.SubIndustry__r.Name!=null?appEm.SubIndustry__r.Name:''; hardcoded
            wrkDetailSal.employerRanking = '';
            wrkDetailSal.totalWorkExp = getTotalWorkExperienceInMonths(appEm.TotalWorkExperience_Years__c,appEm.TotalWorkExperience_Months__c);
            wrkDetailSal.workPermitNo = '';
            wrkDetailSal.tradeLicenseNo = '';
            wrkDetailSal.prevEmployerPhoneNo = '';
            wrkDetailSal.natureOfBusinessSelf = '';
            wrkDetailSal.natureOfBusinessWork = appEm.NatureOfBusinessIndividual__c != null ? appEm.NatureOfBusinessIndividual__c : '';
            wrkDetailSal.department = '';
            wrkDetailSal.prevEmployerName = '';
            wrkDetailSal.subIndustryWork = '';
            wrkDetailSal.pfNumber = '';
            wrkDetailSal.othersWork = (appEm.EmployerName__r.Name != null && appEm.EmployerName__r.Name == 'OTHER') ? (appEm.Others__c != null ? appEm.Others__c : '') : '';
            wrkDetailSal.yearPresentJob = String.valueOf(appEm.WorkingWithCurrentEmployer_Years__c) != null ? String.valueOf(appEm.WorkingWithCurrentEmployer_Years__c) : '';
            wrkDetailSal.tradeLicenseExpiryDate = '';
            wrkDetailSal.noOfpartners = '';
            wrkDetailSal.nameOfPOAHolder = '';
            wrkDetailSal.typeOfOwnership = '';
            wrkDetailSal.nonEarning = '';
            wrkDetailSal.dateOfInceptionWork = '';
            wrkDetailSal.designation = masterDataMap.get('Designation') !=null && appEm.DesignationValues__c !=null ? (masterDataMap.get('Designation').get(appEm.DesignationValues__c) !=null ? masterDataMap.get('Designation').get(appEm.DesignationValues__c) : '') :'' ;   
            wrkDetailSal.labourIdNo = '';
            wrkDetailSal.employerRating = '';
            wrkDetailSal.typeOfOrg = appEm.TypeOfOrganisation__c != null ? appEm.TypeOfOrganisation__c : '';
        } else {
            wrkDetailSal.emplyementType = ''; // Blank
            wrkDetailSal.shareHolding = ''; // Blank
            wrkDetailSal.labourIdExpiryDate = ''; // Blank
            wrkDetailSal.pranNo = ''; // Blank
            wrkDetailSal.associatedSinceInception = ''; // Blank
            wrkDetailSal.indutsryWork = '';
            wrkDetailSal.mcaNumber = ''; // Blank
            wrkDetailSal.uanNumber = ''; // Not capturing
            wrkDetailSal.businessName = '';
            wrkDetailSal.websiteAddress = '';
            wrkDetailSal.employerName = '';
            wrkDetailSal.prevEmployerAddress = ''; // Blank
            wrkDetailSal.industryEmployment = ''; // check this which one should take
            wrkDetailSal.employmentStatus = ''; // Blank
            wrkDetailSal.employeeNo = ''; // Blank
            wrkDetailSal.yearPreviousJobMon = ''; // Blank
            wrkDetailSal.lengthOfBusiness = ''; // blank
            wrkDetailSal.subIndEmplyment = '';
            wrkDetailSal.employerRanking = '';
            wrkDetailSal.totalWorkExp = '';
            wrkDetailSal.workPermitNo = '';
            wrkDetailSal.tradeLicenseNo = '';
            wrkDetailSal.prevEmployerPhoneNo = '';
            wrkDetailSal.natureOfBusinessSelf = '';
            wrkDetailSal.natureOfBusinessWork = '';
            wrkDetailSal.department = '';
            wrkDetailSal.prevEmployerName = '';
            wrkDetailSal.subIndustryWork = '';
            wrkDetailSal.pfNumber = '';
            wrkDetailSal.othersWork = '';
            wrkDetailSal.yearPresentJob = '';
            wrkDetailSal.tradeLicenseExpiryDate = '';
            wrkDetailSal.noOfpartners = '';
            wrkDetailSal.nameOfPOAHolder = '';
            wrkDetailSal.typeOfOwnership = '';
            wrkDetailSal.nonEarning = '';
            wrkDetailSal.dateOfInceptionWork = '';
            wrkDetailSal.designation = '';
            wrkDetailSal.labourIdNo = '';
            wrkDetailSal.employerRating = '';
            wrkDetailSal.typeOfOrg = '';
        }

        return wrkDetailSal;
    }

    //Calculate total months Logic
    public static String getTotalWorkExperienceInMonths(Decimal totalYears, Decimal totalMonths) {

        Decimal yearsInMonths = (totalYears != null) ? totalYears * 12 : 0;
        Decimal months = (totalMonths != null) ? totalMonths : 0;

        // Calculate total months
        Integer totalWorkExperienceInMonths = (yearsInMonths + months).intValue();
        return String.valueOf(totalWorkExperienceInMonths);
    }

}