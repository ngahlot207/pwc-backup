public class ESignDocumentUploadRequestWrapper {
	
    public String reference_id;	//xxxx
	public String docket_title;	//xxxx
	public Boolean description_in_invitation;	//xxxx
	public String docket_description;	//xxxx
	public String remarks;	//xxxx
	public Boolean enable_email_notification;	//xxxx
	public Boolean enable_organisation_seal;	//xxxx
	public String expiry_date;	//DD-MM-YYYY
	public String final_copy_phone_number_list;	//xxxx;xxxx
	public String final_copy_recipients;	//xxxx,xxxx
	public String mode;	//draft
	public String notification_email_list;	//xxxx,xxxx
	public List<Documents> documents;
	public List<SignersInfo> signers_info;
	public WidgetConfiguration widget_configuration;
	public class Documents {
		public String reference_doc_id;	//xxxx
		public String content_type;	//xxxx
		public String return_url;	//xxxx
		public String content;	//xxxx
		public String signature_sequence;	//xxxx
		public CustomParameter custom_parameter;
	}
	public class CustomParameter {
		public String parameter_name;	//xxxxxxxx
	}
	public class SignersInfo {
		public String document_to_be_signed;	//xxxx
		public SignerPosition signer_position;
		public String signer_ref_id;	//xxxx
		public String signer_remarks;	//xxxx
		public String signer_email;	//xxxx
		public String signer_name;	//xxxx
		public String sequence;	//xxxx
		public String page_number;	//xxxx
		public String esign_type;	//xxxx
		public String signer_mobile;	//xxxx
		public SignervalidationInputs signer_validation_inputs;
		public boolean trigger_esign_request;
		public String trigger_esign_request_invitation;	//xxxx
		public String whatsapp_invitation_mode;	//xxxx
		public String signature_type;	//xxxx
		public String access_type;	//xxxx
		public String authentication_mode;	//xxxx
	}
	public class SignerPosition {
		public String appearance;	//xxxx
	}
	public class SignerValidationInputs {
		public String year_of_birth;	//xxxx
		public String gender;	//xxxx
		public String name_as_per_aadhaar;	//xxxx
		public String last_four_digits_of_aadhaar;	//xxxx
	}
	public class WidgetConfiguration {
		public String widget_title;	//xxxx
		public String background_color;	//xxxx
		public String button_color;	//xxxx
		public String button_font_color;	//xxxx
		public String font_family;	//xxxx
		public String esign_with_otp_button_text;	//xxxx
		public String esign_with_biometric_button_text;	//xxxx
		public String user_instruction;	//xxxx
		public String remark_field_label;	//xxxx
		public String usb_signature_title;	//xxxx
	}
	public static ESignDocumentUploadRequestWrapper parse(String json){
		return (ESignDocumentUploadRequestWrapper) System.JSON.deserialize(json, ESignDocumentUploadRequestWrapper.class);
	}

}