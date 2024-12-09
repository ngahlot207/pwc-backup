export function getcreditdeviationColumns(){
    return [
    {
        label: 'Deviation',
        fieldName: 'Deviation__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'Devia_Desrp__c',
        type: 'textarea',

    },
    {
        label: 'Level',
        fieldName: 'Req_Apprv_Level__c',
        type: 'text',

    },
    {
        label: '*Mitigant',
        fieldName: 'Mitigation__c',
        type: 'textarea',

    },
    {
        label: 'Approved By',
        fieldName: 'ApprovedByName__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'DocDesc__c',
        type: 'textarea',
    },
    {
        label: 'Approver Action',
        fieldName: 'Appr_Actn__c',
        type: 'customPicklist',
        editable: false,
        typeAttributes: {
            options: { fieldName: 'pickListOptions' },
            value: { fieldName: 'Appr_Actn__c' },
            context: { fieldName: 'Id' },
            isDisabledRow : {fieldName : 'isDisabledRow'}
        }
    },
    {
        label: '*Remarks (Input Text)',
        fieldName: 'Appr_Remarks__c',
        type: 'textarea',


    }
];
}

export function getPostdeviationColumns(){
    return [
    {
        label: 'Deviation',
        fieldName: 'Deviation__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'Devia_Desrp__c',
        type: 'textarea',

    },
    {
        label: 'Level',
        fieldName: 'Req_Apprv_Level__c',
        type: 'text',

    },
    {
        label: '*Mitigant',
        fieldName: 'Mitigation__c',
        type: 'textarea',

    },
    {
        label: 'Approved By',
        fieldName: 'ApprovedByName__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'DocDesc__c',
        type: 'textarea',
    },
    {
        label: 'Approver Action',
        fieldName: 'Appr_Actn__c',
        type: 'customPicklist',
        editable: false,
        typeAttributes: {
            options: { fieldName: 'pickListOptions' },
            value: { fieldName: 'Appr_Actn__c' },
            context: { fieldName: 'Id' },
            isDisabledRow : {fieldName : 'isDisabledRow'}
        }
    },
    {
        label: '*Remarks (Input Text)',
        fieldName: 'Appr_Remarks__c',
        type: 'textarea',


    }
];
}

export function getDeviationColumns(){
    [
        {
            label: 'Table Name',
            fieldName: 'DeviationCategory__c',
            type: 'text',

        },
        {
            label: 'Disb Deviations/Legal Deviations',
            fieldName: 'Devia_Desrp__c',
            type: 'text',

        },
        {
            label: 'Internal Legal Remarks',
            fieldName: 'IntLegalRem__c',
            type: 'textarea',

        },
        {
            label: 'Deviation Level',
            fieldName: 'Req_Apprv_Level__c',
            type: 'text',

        },
        {
            label: 'Deviation Description',
            fieldName: 'DocDesc__c',
            type: 'textarea',
        },
        {
            label: 'Approver Action',
            fieldName: 'Appr_Actn__c',
            type: 'customPicklist',
            editable: false,
            typeAttributes: {
                options: { fieldName: 'pickListOptions' },
                value: { fieldName: 'Appr_Actn__c' },
                context: { fieldName: 'Id' },
                isDisabledRow : {fieldName : 'isDisabledRow'}
            }
        },
        {
            label: 'Remarks (Input Text)',
            fieldName: 'Appr_Remarks__c',
            type: 'Text',
        }

    ];
}

export function getEcreditdeviationColumns(){
    return [
    {
        label: 'Deviation',
        fieldName: 'Deviation__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'Devia_Desrp__c',
        type: 'textarea',

    },
    {
        label: 'Level',
        fieldName: 'Req_Apprv_Level__c',
        type: 'text',

    },
    {
        label: '*Mitigant',
        fieldName: 'Mitigation__c',
        type: 'textarea',

    },
    {
        label: 'Approved By',
        fieldName: 'ApprovedByName__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'DocDesc__c',
        type: 'textarea',
    },
    {
        label: 'Approver Action',
        fieldName: 'Appr_Actn__c',
        type: 'customPicklist',
        editable: true,
        typeAttributes: {
            options: { fieldName: 'pickListOptions' },
            value: { fieldName: 'Appr_Actn__c' },
            context: { fieldName: 'Id' },
            isDisabledRow : {fieldName : 'isDisabledRow'}
        }
    },
    {
        label: '*Remarks (Input Text)',
        fieldName: 'Appr_Remarks__c',
        type: 'textarea',


    }
];
}

export function getEPostdeviationColumns(){
    return [
    {
        label: 'Deviation',
        fieldName: 'Deviation__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'Devia_Desrp__c',
        type: 'textarea',

    },
    {
        label: 'Level',
        fieldName: 'Req_Apprv_Level__c',
        type: 'text',

    },
    {
        label: '*Mitigant',
        fieldName: 'Mitigation__c',
        type: 'textarea',

    },
    {
        label: 'Approved By',
        fieldName: 'ApprovedByName__c',
        type: 'text',

    },
    {
        label: 'Deviation Description',
        fieldName: 'DocDesc__c',
        type: 'textarea',
    },
    {
        label: 'Approver Action',
        fieldName: 'Appr_Actn__c',
        type: 'customPicklist',
        editable: true,
        typeAttributes: {
            options: { fieldName: 'pickListOptions' },
            value: { fieldName: 'Appr_Actn__c' },
            context: { fieldName: 'Id' },
            isDisabledRow : {fieldName : 'isDisabledRow'}
        }
    },
    {
        label: '*Remarks (Input Text)',
        fieldName: 'Appr_Remarks__c',
        type: 'textarea',


    }
];
}

export function getEDeviationColumns(){
    [
        {
            label: 'Table Name',
            fieldName: 'DeviationCategory__c',
            type: 'text',

        },
        {
            label: 'Disb Deviations/Legal Deviations',
            fieldName: 'Devia_Desrp__c',
            type: 'text',

        },
        {
            label: 'Internal Legal Remarks',
            fieldName: 'IntLegalRem__c',
            type: 'textarea',

        },
        {
            label: 'Deviation Level',
            fieldName: 'Req_Apprv_Level__c',
            type: 'text',

        },
        {
            label: 'Deviation Description',
            fieldName: 'DocDesc__c',
            type: 'textarea',
        },
        {
            label: 'Approver Action',
            fieldName: 'Appr_Actn__c',
            type: 'customPicklist',
            editable: true,
            typeAttributes: {
                options: { fieldName: 'pickListOptions' },
                value: { fieldName: 'Appr_Actn__c' },
                context: { fieldName: 'Id' },
                isDisabledRow : {fieldName : 'isDisabledRow'}
            }
        },
        {
            label: 'Remarks (Input Text)',
            fieldName: 'Appr_Remarks__c',
            type: 'Text',
        }

    ];
}