package alttus.reminders;

import java.io.StringWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONWriter;

import geotech.Database;

public class ReminderController {
	
	private Database db;
	private String userId;
	private ReminderModel[] reminders;
	
	public ReminderController() {
		db = Database.createDatabase();
		userId = null;
		reminders = new ReminderModel[0];
	}
	
	private ReminderModel[] getRemindersForUser(String userId) {
		if (this.userId != null && this.userId.equals(userId)) {
			return this.reminders;
		}
		else {
			String sql = "";
			
			// loading reminders
			sql = 	"SELECT\n" +
					"	reminder_id,\n" +
					"	message\n" +
					"FROM\n" + 
					"	reminders\n" +
					"WHERE\n" +
					"	dismissed = FALSE\n" +
					"	AND next_alarm <= NOW()\n" +
					"	AND recipient_id = " + userId;
			
			ResultSet result = db.query(sql);

			ArrayList<ReminderModel> acc = new ArrayList<ReminderModel>();
			
			try {
				while (result != null && result.next()) {
					acc.add(new ReminderModel(result.getString("reminder_id"), result.getString("message")));
				}
			} catch (SQLException e) {
				System.err.println("ReminderController: error while retrieving reminders for user " + userId);
			}
			
			
			ReminderModel[] r = new ReminderModel[acc.size()];
			acc.toArray(r);
			
			// setting cache
			this.userId = userId;
			this.reminders = r;
			
			return this.reminders;
		}
	}
	
	public boolean hasReminders(String userId) {
		ReminderModel[] r = getRemindersForUser(userId);
		
		return r.length > 0;
	}
	
	public String getRemindersJSON(String userId) throws JSONException {
		ReminderModel[] reminders = getRemindersForUser(userId);
		
		StringWriter out = new StringWriter();
		JSONWriter writer = new JSONWriter(out);
		
		writer.array();
		for (ReminderModel r : reminders) {
			writer.object();
			writer.key("id").value(r.id);
			writer.key("message").value(r.message);
			writer.endObject();
		}
		writer.endArray();
		
		return out.toString();
	}
	
	public boolean dismissReminder(String reminderId, String userId) {
		
		String sql;
		
		sql = 	"UPDATE reminders \n" +
				"SET \n" +
				"	last_viewed = NOW(),\n" +
				"	next_alarm = to_date(to_char(current_date, 'YYYY-MM') || to_char(next_alarm, '-dd'), 'YYYY-MM-dd') + (repeat * '1 month'::INTERVAL), \n" +
				"	dismissed = (TRUE AND (repeat = 0))\n" +
				"WHERE\n" +
				"	reminder_id = " + reminderId + "\n" +
				"	AND recipient_id = " + userId;
		
		return db.update(sql) == 1;
	}
}
