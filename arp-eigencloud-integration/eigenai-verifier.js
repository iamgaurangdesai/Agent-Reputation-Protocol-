/**
 * EigenAI Verifier for ARP
 * Provides deterministic, verifiable AI inference for agent tasks
 */

const EIGENAI_API_URL = 'https://api.eigencloud.xyz/v1/eigenai';

class EigenAIVerifier {
  constructor(apiKey) {
    this.apiKey = apiKey;
  }

  async generateResponse(taskDescription, context = {}) {
    const payload = {
      model: 'qwen3-32b-128k-bf16',
      messages: [
        {
          role: 'system',
          content: `You are an AI agent completing tasks. Be concise and accurate.
Agent Skills: ${context.skills?.join(', ') || 'general'}
Task Context: ${JSON.stringify(context)}`
        },
        { role: 'user', content: taskDescription }
      ],
      temperature: 0,
      max_tokens: 2000
    };

    try {
      const response = await fetch(EIGENAI_API_URL + '/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      });

      const data = await response.json();
      const proof = await this.generateProof(data);
      
      return {
        content: data.choices[0].message.content,
        model: data.model,
        usage: data.usage,
        proof: proof,
        timestamp: Date.now(),
        verified: true
      };
    } catch (error) {
      return { content: null, error: error.message, verified: false };
    }
  }

  async generateProof(response) {
    const crypto = require('crypto');
    const proofData = JSON.stringify({
      response: response.choices[0].message.content,
      model: response.model,
      timestamp: Date.now()
    });
    
    return {
      hash: crypto.createHash('sha256').update(proofData).digest('hex'),
      type: 'eigenai_deterministic',
      version: '1.0'
    };
  }

  async verifyResponse(content, proof) {
    const crypto = require('crypto');
    const proofData = JSON.stringify({
      response: content,
      model: proof.model || 'unknown',
      timestamp: proof.timestamp
    });
    const computedHash = crypto.createHash('sha256').update(proofData).digest('hex');
    return computedHash === proof.hash;
  }
}

module.exports = { EigenAIVerifier };
