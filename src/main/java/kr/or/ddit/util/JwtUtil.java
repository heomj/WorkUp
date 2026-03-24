package kr.or.ddit.util;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtil {

    // 비밀키 생성
    private final String SECRET_STString = "my-secret-key-1234567890-final-project-haha-hihi-rolrole";
    private final SecretKey SECRET_KEY = Keys.hmacShaKeyFor(SECRET_STString.getBytes());

    // 유효 시간: 1시간
    private final long EXPIRATION_TIME = 1000 * 60 * 60;

    // 여기가 토큰 생성임 / 로그인 성공 시 호출되어 사용자에게 줄 문자열을 만드는 곳 -------------------------
    public  String generateToken(String userId) {
        return Jwts.builder()
                .setSubject(userId) // 누가 발급 ㅇㅅㅇ?
                .setIssuedAt(new Date()) // 발급 기간
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME)) // 만료 기간 기록
                .signWith(SECRET_KEY, SignatureAlgorithm.HS256) // 서버 도장 찍기?
                .compact(); // 문자열로 압축
    }

    // 사용자가 토큰 들고오면 그 안에 적힌 id 값 읽기
    public String getUserIdFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(SECRET_KEY) // (1) 우리 서버 도장 준비
                .build()
                .parseClaimsJws(token) // (2) 받은 토큰을 도장과 대조하며 열기
                .getBody() // (3) 내용물(Claims) 꺼내기
                .getSubject(); // (4) 적혀있던 아이디(Subject) 리턴
    }

}
