<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>



<!DOCTYPE html>
  
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FILMUS</title>
    <link rel="icon" href="/resources/img/favicon_noback.ico" type="image/x-icon">
    <link rel="stylesheet" href="/resources/css/bootstrap.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-KyZXEAg3QhqLMpG8r+8fhAXLRk2vvoC2f3B09zVXn8CA5QIVfZOJ3BCsw2P0p/We" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-U1DAWAznBHeqEIlVSCgzq+c9gqGAJn5c/t99JyeKa9xxaYpSvHU5awsuZVVFIhvj" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-migrate/3.3.2/jquery-migrate.min.js"></script>
    <script src="/resources/js/like.js"></script>
    <script src="/resources/js/reply.js"></script>
    <script src="/resources/js/boardReport.js"></script>

    <script>    
    	$(function(){
            console.log("========= COMMENT JS =======")
    		var bnoValue='<c:out value="${board.bno}"/>';
            var nickname='<c:out value="${__LOGIN__.nickname}"/>' 
            var userid='<c:out value="${__LOGIN__.userId}"/>'
            var replyUL=$(".chat");    
            var boardwriter='<c:out value="${board.writer}"/>'
            var modal = $(".modal"); 
            var modalInputReply=modal.find("input[name='content']");
            var modalInputReplyer=modal.find("input[name='nickname']");
            var modalinputReplyDate=modal.find("input[name='insert_ts']");
            var modalModBtn=$("#modalModBtn");
            var modalRemoveBtn=$("#modalRemoveBtn");
            var modalRegisterBtn=$("#modalRegisterBtn");

            //????????? ????????? ?????? ?????? ??????
            if(userid==boardwriter){
                $("#delete").show();
                $("#modifyBtn").show();
            } else{
                $("#delete").hide();
                $("#modifyBtn").hide();
                if("${__LOGIN__}"==""){
                    $("#addReplyBtn").hide()
                    $("#reportBtn").hide()
                }//if
            }//if-else

            //???????????? ?????? ????????? ???????????? ??????
            var isAdmin='${__LOGIN__.isAdmin}'
            console.log("isAdmin::"+isAdmin);
            if(isAdmin==='T'){
                $("#admindeleteBtn").show();
            } else{
                $("#admindeleteBtn").hide();
            }

            //????????? ?????? ??????/???/??????
            var likecheck="${heart.likecheck}"
            console.log(">>>> LIKECHECK >>>> ",likecheck); 
            if(likecheck==1){
                $("#likeimg").attr("src", "/resources/img/fullheart.png");
                $("#likeBtn").on("click",function(e){
                    // likeService.likeChecking(bnoValue);
                    likeService.unLike(bnoValue, userid);
                    alert("???????????? ??????????????????.");
                    $("#likeimg").attr("src", "/resources/img/emptyheart.png");
                    
                    console.log(">>>>>>>like check", likecheck);
                    
                    location.href="/board/get?bno=${board.bno}&currPage=${cri.currPage}&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}"
                })
            }
            if(likecheck==0){
                $("#likeimg").attr("src", "/resources/img/emptyheart.png");
                $("#likeBtn").on("click",function(e){
                    // likeService.likeChecking(bnoValue);
                    likeService.likeIt(bnoValue, userid);
                    alert("???????????? ???????????????.");
                    $("#likeimg").attr("src", "/resources/img/fullheart.png");
                    
                    likecheck=1;
                    console.log(">>>>>>>like check", likecheck);
                    location.href="/board/get?bno=${board.bno}&currPage=${cri.currPage}&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}"
                })
            }
            
            //?????? ????????? ????????????
            showList(1);
            function showList(page){
                console.log("Get Reply List >>")
                replyService.getList({bno:bnoValue,page:page||1},function(list){
                    var str="";
                    if(list==null||list.length==0){
                        str+="<div id='nocomment'>?????? ????????? ????????????.</div>"
                        // return;
                    }//if
                    for(var i=0, len=list.length||0; i<len; i++){
                        str+="      <div class='header'>";
                        str+="          <a href='/mypage/main?userid="+list[i].writer+"'><img class='rounded-circle' src='/resources/img/common.jpg' width='30px' height='30px'></a>";
                        str+="          <strong class='primary-font'>"+list[i].nickname+"</strong>";
                        // str+="          <button type='button' id='reportBtn'> <img src='/resources/img/siren.jpg' width='20px' height='20px'>??????</button>";
                        str+="          <samll class='pull-right text-muted' id='commentTs'>?????? "+replyService.displayTime(list[i].insert_ts)+" <c:if test='"+list[i].update_ts+"'><br>?????? "+replyService.displayTime(list[i].update_ts)+"</c:if>"+"</small>";
                        str+="      </div>"
                        str+="<li class='left clearfix' data-bcno='"+list[i].bcno+"'>";
                        str+="  <div>";
                        str+="      <p id='replycontent'>"+list[i].content+"</p>";
                        str+="   </div>";
                        str+="</li>";
                        str+="<hr>";
                    }
                    replyUL.html(str);
                })//end function
            }//showList
            
            //????????????
            $("#addReplyBtn").on("click",function(e){
                console.log("addReplyBtn")
                modal.find("input").val("");
                modalinputReplyDate.closest("div").hide();
                modal.find("button[id!='modalCloseBtn']").hide();
                modalRegisterBtn.show();
                replyComment.readOnly=false;
                $("#createComment").modal("show");
            })//onclick addReplyBtn
            
            modalRegisterBtn.on("click",function(e){
                var reply={
                    content:modalInputReply.val(),
                    bno:bnoValue,
                    writer:"${__LOGIN__.userId}"
                };
                replyService.add(reply,function(result){
                    alert("????????? ??????????????????."); 
                    modal.find("input").val("");
                    modal.modal("hide");
                    showList(1);
                })
            })//modalRegisterBtn
            
            // $("#replycontent").css('cursor','pointer')
            
            //?????? ????????????
            $(".chat").on("click","li",function(e){
                console.log(" >> chat clicked.");
                bcno=$(this).data("bcno");
                console.log(".chat bcno:"+bcno);
                replyService.get(bcno, function(reply){
                    console.log(reply);
                    modalInputReply.val(reply.content);
                    modalInputReplyer.val(reply.nickname).attr("readonly","readonly");
                    modalinputReplyDate.val(replyService.displayTime(reply.update_ts)).attr("readonly","readonly").hide();
                    modal.data("bcno",reply.bcno);
                    modal.find("button[id!='modalCloseBtn']");
                    if("${__LOGIN__.userId}"==reply.writer){
                        modalModBtn.show();
                        modalRemoveBtn.show();
                        replyComment.readOnly=false;
                    }else{
                        replyComment.readOnly=true;
                        modalModBtn.hide();
                        modalRemoveBtn.hide();
                    }
                    modalRegisterBtn.hide();
                    $("#createComment").modal("show");
                })
            })
            //????????????
            modalModBtn.on("click",function(e){
                console.log("modalModBtn Clicked");
            	var reply2={
                    bcno:bcno, 
                    content: modalInputReply.val()
                };
                console.log("reply2:"+reply2.bcno+ reply2.content)
				replyService.update(reply2, function(result){
                    alert("?????? ???????????????.");
					modal.modal("hide");
					showList(1);
				})
            })
            //????????????
			modalRemoveBtn.on("click",function(e){
                console.log("removeBtn clicked >> bcno:" +bcno);
				replyService.remove(bcno, function(result){
                    alert("?????? ???????????????.");
					modal.modal("hide");
					showList(1);
				})
			})
			//????????????
            $("#reportBtn").on("click",function(e){
                console.log("reportBtn clicked>>")
                $("#reportmodal").modal("show");
            })
			//????????????
            $("#modalReportBtn").on("click",function(e){
            	 var modalReportCode=modal.find("#reportcode").val();
                 console.log(modalReportCode);
                 var modalAccuser=modal.find("input[name='reportwriter']").val();
                 var modalTargetType=modal.find("input[name='reporttype']").val();
                 var modalTarget=modal.find("input[name='reporttarget']").val();
                 var modalSuspect=modal.find("input[name='suspect']").val();
                 var modalReportContent=modal.find("textarea[name='rContent']");
                console.log("modalReportBtn Clicked.");
                var reportinfo={
                    code: modalReportCode,
                    accuser: modalAccuser,
                    target_type: modalTargetType,
                    target: modalTarget,
                    suspect: modalSuspect,
                    content: modalReportContent.val()
                }
                console.log("reportinfo: ", reportinfo);
                reportService.send(reportinfo,function(result){
                    alert("????????? ?????????????????????.");
                    modal.modal("hide");
                })
            })
    	})//jq
    	
    	
        $(function(){
            console.debug("========= BOARD GET JS =======")
            $("#listBtn").on('click',function(){
                console.log(" >>> listBtn button clicked");
                location.href="/board/list?currPage=${cri.currPage}&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}"
            }) //on click
            $("#modifyBtn").on('click',function(){
                console.log(" >>> modifyBtn clicked");
                location.href="/board/modify?bno=${board.bno}&currPage=${cri.currPage}&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}"
            })//onclick

            //????????? ??????
            $("#delete, #admindeleteBtn").on('click',function(){
                console.log("delete clicked.");

                if(confirm("???????????? ?????????????????????????")){
                    let formobj=$('form');
                    formobj.attr('action','/board/remove');
                    formobj.attr('method','post');
                    var inp = $("input")
                    inp.attr("type", "hidden");
                    inp.attr("name", "bno");
                    inp.attr("value", "${board.bno}");
                    formobj.attr('inp');
                    formobj.submit();
                } else{
                	return false;
                }//if-else
            })//delete
            
            
        })//jq
    </script>

    <style>
        #boardGetWrapper{
		    width: 998px;
		    margin: 0 auto;
		    font-size: 20px;
            font-family: 'ELAND ?????????';
            -ms-user-select: none; 
            -moz-user-select: -moz-none;
            -khtml-user-select: none;
            -webkit-user-select: none;
            user-select: none; 
		}
		#commentTs{
			float: right;
		}
        #thiscategory{
            width: 90%;
            height: 100px;
            font-size: 50px;
            font-family: 'ELAND ?????????';
            text-align: center;
            margin: 0 auto;
        }
        #userinfo{
            display: inline-table;
            margin-left: 20px;
            height: 160px;
        }
        #getinfo{
            float: right;
            margin-top: 40px;
            margin-right: 20px;
        }
        #title{
            width: 50%;
            height: 40px;
            font-size: 26px;
            padding: 10px;
            margin-bottom: 20px;
            background-color: #fcfcfc00; 
            border-radius: 30px;
        }
        #content{
            width: 100%;
            height: 100%;
            font-size: 19px;
            padding: 20px;
            background-color: #ffffff00; 
            border-radius: 30px;
            white-space: pre-wrap;           

        }
        #replycontent{
            width: 90%;
            margin-left: 32px;
            margin-top: 10px;
            white-space: pre-wrap;           
         	word-wrap: break-word;
        }
        button {
            margin-left: 20px;
            background-color: white;
            font-family: "ELAND ?????????";
            font-size: 20px;
            font-weight: 400;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            width: auto;
            border: none;
            border-radius: 4px;
            /* box-shadow: 0 4px 6px -1px rgba(169, 235, 255, 0.781), 0 2px 4px -1px rgba(125, 160, 212, 0.425); */
            cursor: pointer;
            transition: 0.5s;
        }
        #threeBtn, #reportBtn{
            float: right;
        }
        #emptyheart{
            width: 20px;
            height: 20px;
        }
        table {
			width:100px;
		    text-align: center;
		    margin-top: 10px ;
            float: right;
		    font-size: 30px;
            font-family: 'ELAND ?????????';
  			border-collapse: collapse;
		  }
		 td{
		  	color: black;
		  	font-size:15px;
		  	padding: 10px;
  		  }
		  th{
		  	font-weight: bold;
		  	border:10px;
		  	margin:10px;
		  	padding:15px;
  		  }
        #commentList{
            display: inline-block;
            font-size: 16px;
        }
        #addReplyBtn{
            display: inline-block;
            float: right;
            font-size: 16px;
        }
        #reportBtn{
            float: right;
        }
        #isDeleteTs{
            margin-top: 200px;
            margin-left: 400px;
        }
        #nocomment{
            margin-bottom: 250px;
        }
    </style>

</head>
<body>
    <%@ include file="/resources/html/header.jsp" %>
    <div id="boardGetWrapper">
    <c:choose>
    <c:when test="${board.delete_ts!=null}">
        <p id="isDeleteTs"><img src="/resources/img/choonsigi.jpg" alt=""><br>????????? ????????? ?????????.</p>
        <button><a>???????????? ????????????</a></button>
    </c:when>
    <c:otherwise>
    <div id="container">

        <form action="/board/get">
            <input type="hidden" name="currPage" value="${cri.currPage}">
            <input type="hidden" name="amount" value="${cri.amount}">
            <input type="hidden" name="pagesPerPage" value="${cri.pagesPerPage}">
            <input type="hidden" name="bno" value="${board.bno}">
            <input type="hidden" name="fname" value="${file.fname}">
            <input type="hidden" name="userId" value="${__LOGIN__.userId}">
            <input type="hidden" name="likecheck" value="${heart.likecheck}">

            
            <div id="thiscategory">
                <c:choose>
                    <c:when test="${board.category=='F'}"><a href="/board/list?category=F&currPage=1&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}">FREE BOARD</a></c:when>
                    <c:when test="${board.category=='N'}"><a href="/board/list?category=N&currPage=1&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}">NEWS BOARD</a></c:when>
                    <c:when test="${board.category=='B'}"><a href="/board/list?category=B&currPage=1&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}">BOASTFULNESS BOARD</a></c:when>
                    <c:when test="${board.category=='R'}"><a href="/board/list?category=R&currPage=1&amount=${cri.amount}&pagesPerPage=${cri.pagesPerPage}">RECOMMENDATION BOARD</a></c:when>
                </c:choose>
            </div>

            <div id="boardinfo">
                <form action="/mypage/main">
                    <ul id="userinfo">
                        <li>
                            <a href="/mypage/main?userid=${board.writer}"><img class="rounded-circle" src="https://younghoon.s3.ap-northeast-2.amazonaws.com/${board.profilePhotoPath}" alt="?????????" width="100px" height="100px"></a>
                        </li>
                        <li><a href="/mypage/main?userid=${board.writer}">${board.nickname}</a></li>
                    </ul>
                    <ul id="getinfo">
                        <li>????????? <fmt:formatDate pattern="yyyy/MM/dd" value="${board.insert_ts}"/></li>
                        <c:if test="${board.update_ts!=null}">
                        	<li>????????? <fmt:formatDate pattern="yyyy/MM/dd" value="${board.update_ts}"/></li>
                    	</c:if> 
                    </ul>
                </form>
            </div>
            
            <!-- ??????  /  ?????????  /  ????????? -->
            <div id="count">
                <table>
                    <tr>
                        <td><button id="reportBtn"><img src='/resources/img/siren.jpg' width='25px' height='25px'></button></td>
                        <td><button><img src="/resources/img/eye-removebg-preview.png" alt="view" width='30px' height='30px'></button> </td>
                        <td>
                            <c:if test="${__LOGIN__==null}">
                                <img src="/resources/img/emptyheart.png" alt="?????????" width="30px" height="30px">
                            </c:if>
                            <c:if test="${__LOGIN__.userId != null}">
                                <button id="likeBtn"><img id="likeimg" src="/resources/img/emptyheart.png" alt="?????????" width="30px" height="30px"></button>
                            </c:if>

                        </td>
                    </tr>
                    <tr>
                        <c:if test="${__LOGIN__.userId != null}">
                            <td>??????</td>
                        </c:if>
                        <c:if test="${__LOGIN__==null}">
                            <td> </td>
                        </c:if>
                        <td> ${board.view_cnt}</td>
                        <td> ${board.like_cnt}</td>
                    </tr>
                </table>
            </div>
            <div>
                <p id="title">
                    [<c:choose>
                       <c:when test="${board.category=='F'}">??????</c:when>
                       <c:when test="${board.category=='N'}">??????</c:when>
                       <c:when test="${board.category=='B'}">??????</c:when>
                       <c:when test="${board.category=='R'}">??????</c:when>
                     </c:choose>] ${board.title}
                </p>

            </div>
            <hr>
            <div id="content">${board.content}</div>
            <hr>
            <div id="threeBtn">
                <button type="button" id="admindeleteBtn" class="btn btn-danger">????????? ?????? ??????</button>
                <button type="button" id="modifyBtn" class="btn btn-outline-dark">??????</button>
                <button type="button" id="delete" class="btn btn-outline-dark">??????</button>
                <button type="button" id="listBtn" class="btn btn-outline-dark">??????</button>
            </div>
            <div>
            	<c:if test="${file.fname!=null}">
	            	<p>&nbsp;</p>
	            	<p>????????????</p>
		            <p><a class="btn btn-primary" href="/board/downloadFile/${board.bno}">${file.fname}</a></p>
	            </c:if>
            </div>

            <br><br><br>
             <div class='row'>
                <div class='col-lg-12'>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <i class="fa fa-comments fa-fw"></i><strong>?????? ??????</strong>
                            <button type="button" id="addReplyBtn" class="btn btn-outline-dark" data-bs-toggle="modal" data-bs-target="#exampleModal">??? ?????? ??????</button>
                            <hr>
                        </div>
                        <div class="panel-body">
                            <ul class="chat">
                                <li class="left clearfix" data-bcno='89' >
                                    <div>
                                        <div class="header">
                                            <strong class="primary-font"></strong>
                                            <small class="pull-right text-muted"></small>
                                        </div>
                                        <p></p>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal -->
            <div class="modal fade" id="createComment" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h5 class="modal-title" id="exampleModalLabel">?????? ??????</h5>
                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="content">??????</label>
                            <input id="replyComment" class="form-control" name='content' value='content'>
                        </div>      
                        <div class="form-group">
                            <input type="hidden" class="form-control" name='writer' >
                        </div>
                        <div class="form-group">
                            <input class="form-control" name='insert_ts' value='2018-01-01 13:13'>
                        </div>

                    </div>
                    <div class="modal-footer">
                      <button id='modalCloseBtn' type="button" class="btn btn-secondary" data-bs-dismiss="modal">??????</button>
                      <button id='modalModBtn' type="button" class="btn btn-warning">??????</button>
                      <button id='modalRemoveBtn' type="button" class="btn btn-danger">??????</button>
                      <button id='modalRegisterBtn' type="button" class="btn btn-primary" data-bs-dismiss="modal">????????????</button>
                    </div>
                  </div>
                </div>
              </div>

            <!-- Modal -->
            <div class="modal fade" id="reportmodal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h5 class="modal-title" id="exampleModalLabel"><img src="/resources/img/siren.jpg" alt="" width="20px" height="20px"> ????????????</h5>
                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div>
                            <label for="reportcode">????????????</label>
                            <select class="form-select" name="reportcode" id='reportcode'>
                                <option value="1">??????/??????</option>
                                <option value="2">????????????</option>
                                <option value="3">??????</option>
                                <option value="4">??????</option>
                              </select>
                              <br>
                        </div>
                        <div class="form-group">
                            ????????? <input type="text" class="form-control" name="nickname" value="${__LOGIN__.nickname}" readonly>
                            <input type="hidden" type="text" class="form-control" name='reportwriter' value="${__LOGIN__.userId}" readonly>
                        </div>
                        <div class="form-group">
                            <label for="reportcontent">??????</label>
                            <textarea name="rContent" class="form-control" cols="44" rows="10" placeholder="* ?????? *&#13;&#10;1. ???????????? ??? ????????? ?????? ??? ????????????.&#13;&#10;2. ????????? ????????? ??? ????????????."></textarea>
                            
                            <!-- <input id="reportcontent" class="form-control" name='reportcontent' value='????????? ???????????????.'> -->
                        </div>      
                        <div class="form-group">
                            <!-- ???????????? -->
                            <input type="hidden" type="text" class="form-control" name="reporttype" value="BNO" readonly> 
                            <input type="hidden" type="text" class="form-control" name="reporttarget" value="${board.bno}" readonly>
                            <input type="hidden" type="text" class="form-control" name="suspect" value="${board.writer}" readonly>                       
                        </div>
                    </div>
                    <div class="modal-footer">
                      <button id='modalCloseBtn' type="button" class="btn btn-secondary" data-bs-dismiss="modal">??????</button>
                      <button id='modalReportBtn' type="button" class="btn btn-danger" data-bs-dismiss="modal">????????????</button>
                    </div> 
                  </div>
                </div>
            </div>

		</form>
    </div>
    </c:otherwise>
    </c:choose>
    </div>
    <%@ include file="/resources/html/footer.jsp" %>

</body>

</html>