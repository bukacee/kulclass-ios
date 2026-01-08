

class HostComment {
  String message;
  String user;
  String image;

  HostComment({required this.message, required this.user, required this.image});
}

List<HostComment> fakeHostCommentListBlank = [];

 List<String> commentUser = [
  "https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=688&q=80",
  "https://images.unsplash.com/photo-1552058544-f2b08422138a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=699&q=80",
  "https://images.unsplash.com/photo-1554151228-14d9def656e4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=686&q=80",
  "https://images.unsplash.com/photo-1500048993953-d23a436266cf?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1169&q=80",
  "https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
  "https://images.unsplash.com/photo-1496302662116-35cc4f36df92?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
  "https://images.unsplash.com/photo-1500259783852-0ca9ce8a64dc?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80",
  "https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=761&q=80",
  "https://images.unsplash.com/photo-1555952517-2e8e729e0b44?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80",
  "https://images.unsplash.com/photo-1542206395-9feb3edaa68d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80"
];
List<String> usrLevel = [
  "Edward Baily",
  "Thomas ",
  "Lily Adams",
  "lsabella kennedy",
  "Charlotte Beiley",
  "Dainel Marshall",
  "Bailey Mia",
  "Isabella",
];
 List<HostComment> fakeHostCommentList = [
  HostComment(message: "I love this", user: usrLevel[0], image: commentUser[0]),
  HostComment(
    message: "Hello Dear",
    user: usrLevel[0],
    image: commentUser[1]),
  HostComment(message: "Joined the class", user: usrLevel[1], image: commentUser[2]),
  HostComment(message: "Excited to learn from this session", user: usrLevel[2], image: commentUser[3]),
  HostComment(message: "Great explanation so far", user: usrLevel[3], image: commentUser[4]),
  HostComment(message: "Very clear presentation and good visuals", user: usrLevel[4], image: commentUser[5]),
  HostComment(message: "Can you share the study resources?", user: usrLevel[5], image: commentUser[6]),
  HostComment(message: "Can I ask a question?", user: usrLevel[2], image: commentUser[7]),
  HostComment(message: "This lesson is very engaging", user: usrLevel[6], image: commentUser[8]),
  HostComment(message: "Looking forward to the next class", user: usrLevel[4], image: commentUser[9]),
  HostComment(message: "Joined", user: usrLevel[0], image: commentUser[0]),
  HostComment(
    message: "Hello",
    user: usrLevel[0],
    image: commentUser[1],
  ),
  HostComment(message: "Thanks for joining the session", user: usrLevel[1], image: commentUser[2]),
  HostComment(message: "The concepts are becoming clearer", user: usrLevel[2], image: commentUser[3]),
  HostComment(message: "Respect for the teaching style", user: usrLevel[3], image: commentUser[4]),
  HostComment(message: "Well-structured content and background", user: usrLevel[4], image: commentUser[5]),
  HostComment(message: "Is there a recording available?", user: usrLevel[5], image: commentUser[6]),
  HostComment(message: "Joined", user: usrLevel[7], image: commentUser[6]),
  HostComment(message: "Can we discuss this topic further?", user: usrLevel[1], image: commentUser[7]),
  HostComment(message: "This explanation really helps", user: usrLevel[6], image: commentUser[8]),
  HostComment(message: "Happy to be part of this learning group", user: usrLevel[3], image: commentUser[9]),
  HostComment(message: "How is everyone doing today?", user: usrLevel[4], image: commentUser[0]),
  HostComment(message: "Hello everyone", user: usrLevel[0], image: commentUser[1]),
  HostComment(message: "Glad to attend this class", user: usrLevel[7], image: commentUser[2]),
  HostComment(message: "Joined", user: usrLevel[0], image: commentUser[3]),
  HostComment(message: "Appreciate the effort put into this lesson", user: usrLevel[1], image: commentUser[4]),
  HostComment(message: "Very informative session", user: usrLevel[2], image: commentUser[5]),
  HostComment(message: "Can you explain that part again?", user: usrLevel[3], image: commentUser[6]),
  HostComment(message: "Can we have a quick recap?", user: usrLevel[1], image: commentUser[7]),
  HostComment(message: "This is a valuable learning experience", user: usrLevel[4], image: commentUser[8]),
  HostComment(message: "Looking forward to applying this knowledge", user: usrLevel[3], image: commentUser[9]),
  HostComment(message: "How are you all finding the lesson?", user: usrLevel[4], image: commentUser[0]),
  HostComment(message: "Hello class", user: usrLevel[0], image: commentUser[1]),
  HostComment(message: "Happy to join today’s session", user: usrLevel[5], image: commentUser[2]),
  HostComment(message: "The examples make it easy to understand", user: usrLevel[6], image: commentUser[3]),
  HostComment(message: "Joined", user: usrLevel[0], image: commentUser[1]),
  HostComment(message: "Great insights shared here", user: usrLevel[7], image: commentUser[4]),
  HostComment(message: "Clear explanation and good pacing", user: usrLevel[0], image: commentUser[5]),
  HostComment(message: "Are there assignments after this?", user: usrLevel[1], image: commentUser[6]),
  HostComment(message: "Can we discuss this in detail?", user: usrLevel[1], image: commentUser[7]),
  HostComment(message: "Very helpful session", user: usrLevel[2], image: commentUser[8]),
  HostComment(message: "Looking forward to the next topic", user: usrLevel[3], image: commentUser[9]),
  HostComment(message: "Joined", user: usrLevel[4], image: commentUser[0]),
  HostComment(message: "Hello everyone", user: usrLevel[0], image: commentUser[1]),
  HostComment(message: "Glad to be learning here", user: usrLevel[3], image: commentUser[2]),
  HostComment(message: "The teaching style is impressive", user: usrLevel[4], image: commentUser[3]),
  HostComment(message: "Well explained concepts", user: usrLevel[5], image: commentUser[4]),
  HostComment(message: "Good visuals and clear examples", user: usrLevel[6], image: commentUser[5]),
  HostComment(message: "Joined", user: usrLevel[3], image: commentUser[9]),
  HostComment(message: "Can you recommend further reading?", user: usrLevel[7], image: commentUser[6]),
  HostComment(message: "Can we ask questions at the end?", user: usrLevel[1], image: commentUser[7]),
  HostComment(message: "Very insightful lesson", user: usrLevel[0], image: commentUser[8]),
  HostComment(message: "Joined", user: usrLevel[3], image: commentUser[9]),
  HostComment(message: "How are you all enjoying the class?", user: usrLevel[4], image: commentUser[0]),
  HostComment(message: "Hello class", user: usrLevel[0], image: commentUser[1]),
  HostComment(message: "Glad to join this session", user: usrLevel[1], image: commentUser[2]),
  HostComment(message: "The explanation is very clear", user: usrLevel[2], image: commentUser[3]),
  HostComment(message: "Good teaching approach", user: usrLevel[3], image: commentUser[4]),
  HostComment(message: "Informative and well-presented", user: usrLevel[4], image: commentUser[5]),
  HostComment(message: "Can we get the slides later?", user: usrLevel[5], image: commentUser[6]),
  HostComment(message: "Joined", user: usrLevel[1], image: commentUser[7]),
  HostComment(message: "Really learning a lot today", user: usrLevel[6], image: commentUser[8]),
  HostComment(message: "Excited for upcoming lessons", user: usrLevel[7], image: commentUser[9]),
];
