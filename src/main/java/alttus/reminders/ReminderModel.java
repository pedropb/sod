package alttus.reminders;

public class ReminderModel {
	public String id;
	public String message;
	
	public ReminderModel() {
		this.id = "";
		this.message = "";
	}
	
	public ReminderModel(String id, String message) {
		this.id = id;
		this.message = message;
	}
	
	
}
