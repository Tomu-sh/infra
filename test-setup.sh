#!/bin/bash

echo "🚀 Testing LightLLM Infrastructure Setup"
echo "========================================"

# Function to wait for service
wait_for_service() {
    local url=$1
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for service at $url..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo "✅ Service is ready!"
            return 0
        fi
        
        echo "   Attempt $attempt/$max_attempts - Service not ready yet..."
        sleep 10
        ((attempt++))
    done
    
    echo "❌ Service failed to become ready after $max_attempts attempts"
    return 1
}

# Test basic connectivity
echo ""
echo "🔍 Testing basic connectivity..."

# Test SSH to VM
echo "Testing SSH connection to VM..."
if ssh -o BatchMode=yes -o ConnectTimeout=5 -p 2222 -i ssh_key ansible@localhost echo "SSH OK" 2>/dev/null; then
    echo "✅ SSH connection successful"
else
    echo "❌ SSH connection failed"
fi

# Test LightLLM service
echo ""
echo "🤖 Testing LightLLM service..."
if wait_for_service "http://localhost:8080"; then
    echo "✅ LightLLM service is accessible"
    
    # Test models endpoint
    echo "📡 Testing models endpoint..."
    models_response=$(curl -s http://localhost:8080/v1/models 2>/dev/null)
    
    if [[ $? -eq 0 && -n "$models_response" ]]; then
        echo "✅ Models endpoint responding"
        echo "Available models:"
        echo "$models_response" | jq -r '.data[].id' 2>/dev/null || echo "Raw: $models_response"
        
        # Test a simple chat completion
        echo ""
        echo "🧪 Testing chat completion..."
        chat_response=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
            -H "Content-Type: application/json" \
            -d '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "Hello!"}], "max_tokens": 10}' 2>/dev/null)
        
        if [[ $? -eq 0 && -n "$chat_response" ]]; then
            content=$(echo "$chat_response" | jq -r '.choices[0].message.content' 2>/dev/null)
            if [[ "$content" != "null" && -n "$content" ]]; then
                echo "✅ Chat completion working: $content"
            else
                echo "⚠️  Chat response: $chat_response"
            fi
        else
            echo "❌ Chat completion failed"
        fi
    else
        echo "⚠️  Models endpoint issue"
    fi
else
    echo "❌ LightLLM service is not accessible"
fi

echo ""
echo "🎉 Test completed!"
echo ""
echo "💡 To test manually:"
echo "   curl http://localhost:8080/v1/models"
echo ""
echo "🛑 To stop the demo:"
echo "   make stop"
