package org.glite.security.voms.admin.common.tasks;

import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.glite.security.voms.admin.dao.generic.DAOFactory;
import org.glite.security.voms.admin.dao.generic.TaskDAO;
import org.glite.security.voms.admin.database.HibernateFactory;
import org.glite.security.voms.admin.model.task.Task;
import org.glite.security.voms.admin.model.task.Task.TaskStatus;

public class TaskStatusUpdater extends TimerTask {

	public static Log log = LogFactory.getLog(TaskStatusUpdater.class);
	
	private static TaskStatusUpdater instance = null;
	
	Timer timer;
	
	private TaskStatusUpdater(Timer t) {
		timer = t;
		
		if (timer != null){
			
			long period = 10L;
			
			log.info("Scheduling TaskStatusUpdater with period: "+ period+" seconds.");
			timer.schedule(this,5*1000, period*1000);
			
		}
		
	}
	
	
	public static TaskStatusUpdater instance(Timer t){
	
		if (instance == null)
			instance = new TaskStatusUpdater(t);
		
		return instance;
		
	}
	
	
	@Override
	public void run() {
		// log.info("TaskStatusUpdater started...");
		
		HibernateFactory.beginTransaction();
		
		TaskDAO taskDAO = DAOFactory.instance().getTaskDAO();
		
		List<Task> activeTasks = taskDAO.getActiveTasks();
		
		for (Task t: activeTasks){
			
			// log.debug("Found active task :"+t);
			Date now = new Date();
			
			if (t.getExpiryDate().before(now)){
				log.debug("Task "+t+" has expired, setting its status to EXPIRED.");
				t.setStatus(TaskStatus.EXPIRED);
				
			}	
		}
		
		HibernateFactory.commitTransaction();
		// log.info("TaskStatusUpdater done.");
	}
	

}