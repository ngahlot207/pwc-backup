public class UpdateComCompDetailsResponseWrapper {
    public Metadata metadata;
	public Data data;
	public String message;

	public class Metadata {
		public String api_version;
	}

	public class Data {
		public String request_id;
	}

}