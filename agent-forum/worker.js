// Cloudflare Worker - Agent Forum API
// 把这个代码复制到 Cloudflare Workers

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  const path = url.pathname
  
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  }
  
  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }
  
  try {
    // 获取所有留言
    if (path === '/api/messages' && request.method === 'GET') {
      const data = await MESSAGES.get('all')
      return new Response(data || '[]', {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    
    // 发送留言
    if (path === '/api/messages' && request.method === 'POST') {
      const body = await request.json()
      const data = await MESSAGES.get('all')
      let messages = data ? JSON.parse(data) : []
      
      const newMessage = {
        id: 'msg_' + Date.now(),
        author: body.author || '匿名',
        content: body.content,
        timestamp: new Date().toISOString(),
        replies: []
      }
      
      messages.unshift(newMessage)
      await MESSAGES.put('all', JSON.stringify(messages))
      
      return new Response(JSON.stringify(newMessage), {
        status: 201,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    
    // 回复留言
    if (path.match(/^\/api\/messages\/.+\/reply$/) && request.method === 'POST') {
      const messageId = path.split('/')[3]
      const body = await request.json()
      
      const data = await MESSAGES.get('all')
      let messages = data ? JSON.parse(data) : []
      
      const message = messages.find(m => m.id === messageId)
      if (!message) {
        return new Response(JSON.stringify({ error: 'Message not found' }), {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })
      }
      
      const reply = {
        id: 'reply_' + Date.now(),
        author: body.author || '匿名',
        content: body.content,
        timestamp: new Date().toISOString()
      }
      
      message.replies = message.replies || []
      message.replies.push(reply)
      
      await MESSAGES.put('all', JSON.stringify(messages))
      
      return new Response(JSON.stringify(message), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    
    return new Response('Not Found', { status: 404 })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
}
