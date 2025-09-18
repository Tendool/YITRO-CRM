#!/bin/bash

# Debug JavaScript Execution and React Mounting
echo "🔍 Debugging JavaScript execution for React mounting..."

# Step 1: Check if new assets exist and are accessible
echo "📁 Step 1: Checking new asset files..."
echo "New assets should be:"
curl -s https://dealhub.yitrobc.net | grep -E "(\.js|\.css)" || echo "No asset references found"

echo ""
echo "Testing new JavaScript file accessibility:"
curl -I http://localhost:3000/assets/index-DnRq4HKQ.js 2>/dev/null && echo "✅ New JS file accessible" || echo "❌ New JS file not accessible"

echo "Testing new CSS file accessibility:"
curl -I http://localhost:3000/assets/index-BOrlOmzW.css 2>/dev/null && echo "✅ New CSS file accessible" || echo "❌ New CSS file not accessible"

# Step 2: Check first and last parts of JavaScript for syntax issues
echo ""
echo "📝 Step 2: Checking JavaScript file structure..."
echo "=== First 500 characters of JS file ==="
curl -s http://localhost:3000/assets/index-DnRq4HKQ.js | head -c 500
echo ""
echo "=== Last 200 characters of JS file ==="
curl -s http://localhost:3000/assets/index-DnRq4HKQ.js | tail -c 200
echo ""

# Step 3: Check for common JavaScript errors in the built file
echo ""
echo "🔍 Step 3: Scanning for JavaScript errors..."
JS_FILE_CONTENT=$(curl -s http://localhost:3000/assets/index-DnRq4HKQ.js)
if echo "$JS_FILE_CONTENT" | grep -q "import.*React"; then
    echo "✅ React import found in JS"
else
    echo "❌ No React import found in JS"
fi

if echo "$JS_FILE_CONTENT" | grep -q "createElement"; then
    echo "✅ React createElement found"
else
    echo "❌ No React createElement found"
fi

if echo "$JS_FILE_CONTENT" | grep -q "createRoot\|render"; then
    echo "✅ React mounting code found"
else
    echo "❌ No React mounting code found"
fi

# Step 4: Check source files to understand the build
echo ""
echo "📁 Step 4: Checking source files..."
if [ -f "client/App.tsx" ]; then
    echo "✅ client/App.tsx exists"
    grep -n "createRoot\|render" client/App.tsx || echo "No mounting code in App.tsx"
else
    echo "❌ client/App.tsx not found"
fi

if [ -f "index.html" ]; then
    echo "✅ index.html exists"
    grep -n "script.*App.tsx" index.html || echo "No App.tsx reference in index.html"
else
    echo "❌ index.html not found"
fi

# Step 5: Check if there are any build or environment issues
echo ""
echo "📝 Step 5: Checking environment and build config..."
echo "NODE_ENV: $NODE_ENV"
echo "Build output structure:"
ls -la dist/spa/ 2>/dev/null || echo "No dist/spa directory"

# Step 6: Test a simple JavaScript execution
echo ""
echo "🧪 Step 6: Testing basic JavaScript execution..."
# Create a simple test file to see if JS execution works at all
cat > test-js.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Test JS</title></head>
<body>
<div id="test-div">Loading...</div>
<script>
console.log("JavaScript is executing");
document.getElementById('test-div').innerHTML = 'JavaScript Works!';
</script>
</body>
</html>
EOF

# Serve the test file
cp test-js.html dist/spa/ 2>/dev/null || mkdir -p dist/spa && cp test-js.html dist/spa/

echo "Testing basic JavaScript execution:"
curl -s http://localhost:3000/test-js.html | grep -E "(Loading|JavaScript)" || echo "Test file not accessible"

# Step 7: Check PM2 logs for any frontend errors
echo ""
echo "📝 Step 7: Recent PM2 logs..."
pm2 logs --lines 15 | grep -E "(error|Error|frontend|React)" || echo "No React/frontend errors in logs"

# Cleanup
rm -f test-js.html dist/spa/test-js.html 2>/dev/null

echo ""
echo "🔧 Next debugging steps:"
echo "1. Open https://dealhub.yitrobc.net in browser"
echo "2. Press F12 for Developer Tools"  
echo "3. Check Console tab for JavaScript errors"
echo "4. Check Network tab to see if JS file loads"
echo "5. If errors found, try: npm run dev (development mode)"
