package kr.or.ddit.advice;


import kr.or.ddit.controller.admin.status.HeartbeatController;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

@Aspect
@Component
@Slf4j
public class PerformanceAspect {

    @Around("execution(* kr.or.ddit..*.*(..))")
    public Object measureExecutionTime(@NonNull ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();

        // 1. 클래스명과 메서드명 추출
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = joinPoint.getSignature().getName();

        // 2. 🕵️‍♂️ 박동이 검문소 (Noise 필터링)
        // 지가 지를 감시하거나, 보안 필터/토큰 체크 등 비즈니스 로직이 아닌 건 제외!
        boolean isNoise = methodName.equals("getHeartbeat")
                || methodName.equals("doFilterInternal")
                || methodName.equals("getUserIdFromToken")
                || className.contains("Proxy")
                || className.contains("Alarm")
                || className.contains("HeartbeatController")
                || className.contains("ChatHandler");

        if (!isNoise) {
            HeartbeatController.lastMethod = className + "." + methodName;
            HeartbeatController.lastTime = System.currentTimeMillis();

            log.info("[Start] Method: {}", methodName);
        }

        try {
            // 실제 타겟 메서드 실행
            return joinPoint.proceed();
        } finally {
            long endTime = System.currentTimeMillis();
            long duration = endTime - startTime;

            if (!isNoise) {
                log.info("[End] Method: {} | Execution Time: {}ms", methodName, duration);
            }
        }
    }
}
