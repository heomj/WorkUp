<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.css">
<html lang="ko">
<style>
    /* 전체 레이아웃 스타일 */
    .container { margin-top: 20px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }

    /* 카드 디자인 */
    .card {
        border: 1px solid #eaeaec;
        border-radius: 12px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        padding: 20px;
        background: #fff;
    }

    /* 입력 필드 디자인 */
    .form-control {
        border: 1px solid #dcdcdc;
        border-radius: 8px;
        padding: 10px 14px;
        margin-bottom: 15px;
        width: 100%;
        box-sizing: border-box;
        transition: border-color 0.2s, box-shadow 0.2s;
    }
    .form-control:focus { border-color: #696CFF; box-shadow: 0 0 0 3px rgba(105, 108, 255, 0.1); outline: none; }

    /* 멘션 버튼 */
    .mention-btn, .mention-btnCc {
        display: inline-flex;
        align-items: center;
        background-color: #f0f0ff;
        color: #696CFF;
        border: 1px solid #d1d1ff;
        border-radius: 16px;
        padding: 4px 10px;
        margin: 2px 4px;
        font-weight: 600;
        font-size: 13px;
        transition: background 0.2s;
    }
    .mention-btn:hover, .mention-btnCc:hover { background-color: #e0e0ff; }

    /* 삭제(x) 버튼 */
    .del-mention, .del-mentionCc {
        margin-left: 6px;
        cursor: pointer;
        font-weight: bold;
        color: #999;
    }
    .del-mention:hover, .del-mentionCc:hover { color: #696CFF; }

    /* 버튼 스타일 */
    .btn-primary {
        background-color: #696CFF;
        color: #fff;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        cursor: pointer;
        font-weight: 600;
    }
    .btn-primary:hover { background-color: #5a5ce6; }

    /* Tribute 검색 결과 컨테이너 */
    .tribute-container {
        position: absolute;
        z-index: 999999;
        background-color: #fff;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        border-radius: 8px;
        border: 1px solid #eaeaec;
        padding: 5px 0;
        max-height: 300px;
        overflow: auto;
    }
    .tribute-container ul { margin: 0; padding: 0; list-style: none; }
    .tribute-container li {
        padding: 10px 15px;
        cursor: pointer;
        font-size: 14px;
        color: #566a7f;
    }
    .tribute-container li.highlight, .tribute-container li:hover {
        background-color: rgba(105, 108, 255, 0.08);
        color: #696CFF;
    }
</style>

<div class="container">
    <h3>📢 유틸화 테스트 알람 존</h3>
    <div class="card p-3">
        <input type="text" id="msg" class="form-control" placeholder="전송할 알림 메시지(요약) 입력" />
        <input type="text" id="almDtl" class="form-control" placeholder="전송할 알림 메시지(상세) 입력" />
        <%--<input type="text" id="almIcon" class="form-control" placeholder="success, error, warning, info, question" />--%>
        <select id="almIcon" class="form-control" >
            <option value="success">success</option>
            <option value="error">error</option>
            <option value="warning">warning</option>
            <option value="info">info</option>
            <option value="question">question</option>
        </select>
        <select id="almSndrIcon" class="form-control" >
            <option value="myAva">내 아바타 보이기</option>
            <option value="defaultAva">기본 아바타 보이기</option>
            <option value="myProfile">내 프로필 보이기</option>
            <option value="defaultIcon">기본 아이콘(확성기)</option>
        </select>
        <div class="mb-3">
            <label class="form-label fw-bold">받는 사람</label>
            <div class="form-control" id="receiver" name="almRcvrId" contenteditable="true"></div>
        </div>
        <button type="button" class="btn btn-primary mt-2" onclick="sendTestAlarm()">알림 전송</button>
    </div>
</div>

<div class="container">

    <h3>📢 "TO" 키워드로 메시지 커스텀 테스트 존</h3>
    <div class="card p-3">
        <input type="text" id="msg2" class="form-control" placeholder="전송할 알림 메시지 입력" />
        <input type="text" id="almDtl2" class="form-control" placeholder="전송할 알림 메시지(상세) 입력" />
        <select>
            <option>success</option>
            <option>error</option>
            <option>warning</option>
            <option>info</option>
            <option>question</option>
        </select>
        <input type="text" id="almIcon2" class="form-control" placeholder="success, error, warning, info, question" />
        <div class="mb-3">
            <label class="form-label fw-bold">받는 사람</label>
            <div class="form-control" id="receiver2" name="almRcvrId" contenteditable="true"></div>
        </div>
        <button type="button" class="btn btn-primary mt-2" onclick="sendTestAlarm2()">알림 전송</button>
    </div>
</div>

<script type="text/javascript">
    document.addEventListener("DOMContentLoaded", function () {
        const tribute = new Tribute({
            trigger: '@',
            lookup: (item) => item.empId + "("+item.empNm+")",
            fillAttr: (item) => item.empId + "("+item.empNm+")",
            requireAnyChar: true,
            values: function (text, cb) {
                fetch('/email/search?query=' + text)
                    .then(res => res.json())
                    .then(data => {
                        const selectedInReceiver = Array.from(document.querySelectorAll('#receiver .mention-btn')).map(span => span.getAttribute('data-no'));
                        const selectedInCc = Array.from(document.querySelectorAll('#cC .mention-btnCc')).map(span => span.getAttribute('data-no'));
                        const allSelectedIds = [...selectedInReceiver, ...selectedInCc];
                        const filteredData = data.filter(item => !allSelectedIds.includes(String(item.empId)));
                        cb(filteredData);
                    })
                    .catch(err => cb([]));
            },
            selectTemplate: function (item) {
                if (typeof item === 'undefined') return null;
                return '<span class="mention-btn" data-no="' + item.original.empId + '" contenteditable="false">'
                    + '@' + item.original.empNm
                    + '<a class="del-mention">X</a>'
                    + '</span>&nbsp; <input type=hidden name="emlRcvrId" value="'+item.original.empId+'">';
            },
            noMatchTemplate: function () {
                return '<li>결과가 없습니다</li>';
            }
        });

        tribute.attach(document.getElementById('receiver'));
        tribute.attach(document.getElementById('receiver2'));

        document.getElementById('receiver').addEventListener('click', function(e) {
            if (e.target && e.target.classList.contains('del-mention')) {
                const mentionBtn = e.target.closest('.mention-btn');
                if (mentionBtn) mentionBtn.remove();
            }
        });

        document.getElementById('receiver2').addEventListener('click', function(e) {
            if (e.target && e.target.classList.contains('del-mention')) {
                const mentionBtn = e.target.closest('.mention-btn');
                if (mentionBtn) mentionBtn.remove();
            }
        });
    });

    function sendTestAlarm(){
        const almRcvrNos = Array.from(document.querySelectorAll('#receiver .mention-btn')).map(span => span.getAttribute('data-no'));
        let msg = document.querySelector("#msg").value;
        let almDtl = document.querySelector("#almDtl").value;
        let almIcon = document.querySelector("#almIcon").value;
        let almSndrIcon = document.querySelector("#almSndrIcon").value;
        const data = { "almIcon":almIcon, "almMsg":msg, "almDtl":almDtl, "almRcvrNos" : almRcvrNos, "almSndrIcon":almSndrIcon };

        axios.post("/alarm/sendtest", data, { headers : { "Content-Type":"application/json;utf-8" } })
            .then(response=>{ /*document.querySelector("#msg").value=""; */})
            .catch(err=>{ console.error("err : ", err) });
    }

    function sendTestAlarm2(){
        const almRcvrNos = Array.from(document.querySelectorAll('#receiver2 .mention-btn')).map(span => span.getAttribute('data-no'));
        let msg = document.querySelector("#msg2").value;
        let almDtl = document.querySelector("#almDtl2").value;
        let almIcon = document.querySelector("#almIcon2").value;
        const data = { "almIcon":almIcon, "almMsg":msg, "almDtl":almDtl, "almRcvrNos" : almRcvrNos };

        axios.post("/alarm/sendtest2", data, { headers : { "Content-Type":"application/json;utf-8" } })
            .then(response=>{ document.querySelector("#msg2").value=""; })
            .catch(err=>{ console.error("err : ", err) });
    }
</script>