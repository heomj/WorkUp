package kr.or.ddit.batch;

import kr.or.ddit.mapper.project.MyProjectMapper;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskParticipantVO;
import kr.or.ddit.vo.project.TaskVO;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.batch.MyBatisBatchItemWriter;
import org.mybatis.spring.batch.MyBatisPagingItemReader;
import org.mybatis.spring.batch.builder.MyBatisBatchItemWriterBuilder;
import org.mybatis.spring.batch.builder.MyBatisPagingItemReaderBuilder;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.ExecutionContext;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.PlatformTransactionManager;

import java.util.ArrayList;
import java.util.List;
@Configuration
@EnableScheduling
public class BatchConfig {

    @Autowired
    private MyProjectMapper myProjectMapper;
    @Autowired
    private SqlSessionFactory sqlSessionFactory;
    @Autowired
    private AlarmController alarmController;

    // (2-1) Job: 프로젝트 지연 및 알람
    @Bean
    public Job firstProjectJob(JobRepository jobRepository, Step firstProjectStep, Step secondProjectStep) {
        return new JobBuilder("firstProjectJob", jobRepository) // 이름을 다르게!
                .start(firstProjectStep)
                .next(secondProjectStep)
                .build();
    }

    // (2-2) Job: 일감(Task) 지연 청크 처리
    @Bean
    public Job secondTaskJob(JobRepository jobRepository, Step fistTaskStep) {
        return new JobBuilder("secondTaskJob", jobRepository) // 이름을 다르게!
                .start(fistTaskStep)
                .build();
    }

    // (3) Step 1: 프로젝트 상태 업데이트 및 ID 저장
    @Bean
    public Step firstProjectStep(JobRepository jobRepository, PlatformTransactionManager transactionManager) {
        return new StepBuilder("firstProjectStep", jobRepository)
                .tasklet((contribution, chunkContext) -> {
                    List<Integer> targetNos = myProjectMapper.getDelayedProjectIds();
                    List<Integer> targetempIds = myProjectMapper.getDelayedProjectempIds();

                    myProjectMapper.updateDelayedProjects();

                    ExecutionContext executionContext = chunkContext.getStepContext().getStepExecution()
                            .getJobExecution().getExecutionContext();

                    executionContext.put("updatedProjectNos", targetNos);
                    executionContext.put("updatedProjectempIds", targetempIds);

                    return RepeatStatus.FINISHED;
                }, transactionManager)
                .build();
    }

    // (4) Step 2: 담당자들에게 알람 발송 (반복문 추가!)
    @Bean
    public Step secondProjectStep(JobRepository jobRepository, PlatformTransactionManager transactionManager){
        return new StepBuilder("secondProjectStep", jobRepository)
                .tasklet((contribution, chunkContext) -> {
                    ExecutionContext jobContext = chunkContext.getStepContext().getStepExecution()
                            .getJobExecution().getExecutionContext();

                    List<Integer> targetempIds = (List<Integer>) jobContext.get("updatedProjectempIds");
                    if (targetempIds != null) {
                            AlarmVO alarmVO = new AlarmVO();
                            alarmVO.setAlmIcon("error");
                            alarmVO.setAlmMsg("<span style='color:red;'>프로젝트 지연 알람</span>");
                            alarmVO.setAlmDtl("팀장님, 프로젝트가 <span style='color:red;'>지연처리</span>되었습니다. 확인 바랍니다.");
                        alarmVO.setAlmRcvrNos(targetempIds);
                        // 실제 담당자(empId)에게 알람 전송
                            // 실제 담당자(empId)에게 알람 전송
                            alarmController.sendAlarm(12, alarmVO, "/projectmanage", "프로젝트");
                    }
                    return RepeatStatus.FINISHED;
                }, transactionManager)
                .build();
    }

    // (5) Step 3: 일감(Task) 청크 처리
    @Bean
    public Step fistTaskStep(JobRepository jobRepository, PlatformTransactionManager transactionManager){
        return new StepBuilder("fistTaskStep", jobRepository) // 이름 중복 피하기
                .<TaskVO, TaskVO>chunk(100, transactionManager)
                .reader(projectReader())
                .processor(projectProcessor())
                .writer(projectWriter())
                .build();
    }

    @Bean
    public MyBatisPagingItemReader<TaskVO> projectReader() {
        return new MyBatisPagingItemReaderBuilder<TaskVO>()
                .sqlSessionFactory(sqlSessionFactory)
                .queryId("kr.or.ddit.mapper.project.MyProjectMapper.getDelayedTasks")
                .pageSize(100)
                .saveState(false)
                .build();
    }

    @Bean
    public ItemProcessor<TaskVO, TaskVO> projectProcessor() {
        return taskVO -> {
            taskVO.setTaskStts("지연"); // 큰따옴표로 수정
            return taskVO;
        };
    }

    @Bean
    public ItemWriter<TaskVO> projectWriter() {
        // 1. DB 업데이트를 담당할 기본 기계를 하나 만듭니다.
        MyBatisBatchItemWriter<TaskVO> dbWriter = new MyBatisBatchItemWriterBuilder<TaskVO>()
                .sqlSessionFactory(sqlSessionFactory)
                .statementId("kr.or.ddit.mapper.project.MyProjectMapper.updateDelayedTasks")
                .build();

        // 2. 이 기계에 알람 기능을 덧붙입니다.
        return chunk -> {
            // A. 먼저 DB 업데이트를 싹 실행합니다. (에러 없이 안전하게!)
            dbWriter.write(chunk);

            // B. 업데이트가 끝난 뒤에 알람을 쏩니다.
            for (TaskVO task : chunk) {
                AlarmVO alarmVO = new AlarmVO();
                alarmVO.setAlmMsg("<span style='color:red;'>일감 지연 알람</span>");
                alarmVO.setAlmDtl("[" + task.getTaskTtl() + "] 일감이 지연되었습니다.");

                List<Integer> almRcvrNos = new ArrayList<>();
                if (task.getTaskParticipantVOList() != null) {
                    for (TaskParticipantVO participant : task.getTaskParticipantVOList()) {
                        almRcvrNos.add(participant.getEmpId());
                    }
                }
                alarmVO.setAlmRcvrNos(almRcvrNos);

                // 알람 발송
                alarmController.sendAlarm(12, alarmVO, "/projectmanage", "프로젝트");
            }
        };
    }

}