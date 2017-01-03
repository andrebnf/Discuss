import {Socket} from "phoenix"
let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

const createSocket = (topicId) => {
  let commentsContainer = document.querySelector("#comments-list");
  let inputText = document.querySelector('textarea');

  let channel = socket.channel(`comments:${topicId}`, {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  document.querySelector('button').addEventListener('click', () => {
    const content = inputText.value;
    channel.push('comment:add', { content: content });
  });

  channel.on("new_comment", payload => {
    let messageItem = document.createElement("li");
    messageItem.classList.add('collection-item');
    messageItem.innerText = payload.content;
    commentsContainer.appendChild(messageItem);
    inputText.value = '';
  })
}

window.createSocket = createSocket;
