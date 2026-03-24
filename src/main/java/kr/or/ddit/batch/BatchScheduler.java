package kr.or.ddit.batch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class BatchScheduler {

    @Autowired
    private JobLauncher jobLauncher;
    @Autowired
    @Qualifier("firstProjectJob") // (1) 프로젝트 잡을 돌릴 거라면 이름을 확실히 명시!
    private Job firstProjectJob;

    @Autowired
    @Qualifier("secondTaskJob")    // (2) 일감 잡도 돌릴 거라면 추가!
    private Job secondTaskJob;
    // @Scheduled: 언제 실행할지 정합니다.
    // cron = "초 분 시 일 월 요일"
    // 예: "0 0 1 * * *" -> 매일 새벽 1시 0분 0초에 실행
    // 테스트용: "0 * * * * *" -> 매 분 0초마다 실행
    @Scheduled(cron="0 14 14 * * *")
    public void runDelayedProjectUpdateJob() {
        try {
            // 실행할 때마다 '현재 시간'을 파라미터로 넣어줍니다.
            // 그래야 배치가 "아, 이건 매일 새로 하는 숙제구나!" 하고 매번 실행해요.
            JobParameters params = new JobParametersBuilder()
                    .addLong("timestamp", System.currentTimeMillis())
                    .toJobParameters();

            jobLauncher.run(firstProjectJob, params);

        } catch (Exception e) {
            System.err.println("배치 스케줄러 실행 중 에러 발생: " + e.getMessage());
        }
    }

    @Scheduled(cron="0 31 14 * * *")
    public void runDelayedTaskUpdateJob() {
        try {
            // 실행할 때마다 '현재 시간'을 파라미터로 넣어줍니다.
            // 그래야 배치가 "아, 이건 매일 새로 하는 숙제구나!" 하고 매번 실행해요.
            JobParameters params = new JobParametersBuilder()
                    .addLong("timestamp", System.currentTimeMillis())
                    .toJobParameters();

            jobLauncher.run(secondTaskJob, params);

        } catch (Exception e) {
            System.err.println("배치 스케줄러 실행 중 에러 발생: " + e.getMessage());
        }
    }

}

