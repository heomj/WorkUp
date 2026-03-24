package kr.or.ddit.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.mapper.BoardMapper;
import kr.or.ddit.mapper.CommentMapper;
import kr.or.ddit.service.CommentService;
import kr.or.ddit.service.AlarmService; // 알람 서비스 주입
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.CommentVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CommentServiceImpl implements CommentService {

    @Autowired
    private CommentMapper commentMapper;
    
    @Autowired
    private BoardMapper boardMapper;

    @Autowired
    private AlarmService alarmService; // 30년 차의 팁: 전용 서비스를 써야 로직이 깔끔하네.

    @Override
    public List<CommentVO> selectCommentList(int bbsNo) {
        return this.commentMapper.selectCommentList(bbsNo);
    }

    /**
     * 댓글 등록 후 최신 목록 리턴 + 고도화된 알람 발송
     */
    @Transactional
    @Override
    public List<CommentVO> insertCommentAndList(CommentVO commentVO) {
        // 1. 댓글 등록
        int result = this.commentMapper.insertComment(commentVO);
        
        if(result > 0) {
			/*
			 * // 2. 알람 발송을 위한 데이터 준비 // 원글 작성자 사번을 가져오네. int boardWriterId =
			 * this.boardMapper.getBoardWriterId(commentVO.getCmntBbsNo());
			 * 
			 * // 작성자와 댓글자가 다를 때만 3단계 알람 발송 처리 if(boardWriterId != commentVO.getEmpId()) {
			 * AlarmVO alarmVO = new AlarmVO();
			 * 
			 * // (1) 알람 내용 및 링크 설정 alarmVO.setAlmMsg("작성하신 게시글에 새로운 댓글이 달렸습니다.");
			 * alarmVO.setAlmUrl("/board/detail?bbsNo=" + commentVO.getCmntBbsNo());
			 * 
			 * // (2) 발송자 정보 설정 (현재 댓글 쓴 사람) alarmVO.setSndrEmpId(commentVO.getEmpId());
			 * 
			 * // (3) 수신자 정보 설정 (원글 작성자) alarmVO.setRcvrEmpId(boardWriterId);
			 * 
			 * // (4) 알람 서비스 호출 (내부에서 ALARM, SEND, RECEIVE 테이블 3개 동시 인서트)
			 * this.alarmService.insertAlarm(alarmVO);
			 * log.info("댓글 알람 발송 완료: 수신자-{}, 발송자-{}", boardWriterId, commentVO.getEmpId());
			 * }
			 */
        }
        return this.commentMapper.selectCommentList(commentVO.getCmntBbsNo());
    }

    @Transactional
    @Override
    public List<CommentVO> updateCommentAndList(CommentVO commentVO) {
        int result = this.commentMapper.updateComment(commentVO);
        log.info("updateComment result : {}", result);
        return this.commentMapper.selectCommentList(commentVO.getCmntBbsNo());
    }

    @Transactional
    @Override
    public List<CommentVO> deleteCommentAndList(CommentVO commentVO) {
        int result = this.commentMapper.deleteComment(commentVO.getCmntNo());
        log.info("deleteComment result : {}", result);
        return this.commentMapper.selectCommentList(commentVO.getCmntBbsNo());
    }

    @Transactional
    @Override
    public int toggleCommentLike(Map<String, Object> map) {
        int count = this.commentMapper.checkLikeExists(map);
        int result = 0;
        if (count > 0) {
            result = this.commentMapper.deleteLike(map);
        } else {
            result = this.commentMapper.insertLike(map);
            
            // [추가 팁] 좋아요 알람도 원하면 여기서 insertAlarm 호출하면 되겠지?
        }
        return result;
    }
    
    @Override
    public CommentVO selectCommentDetail(int cmntNo) {
        return commentMapper.selectCommentDetail(cmntNo);
    }
}