# AI Vision Chat
Chat with large languages models about the contents of an image via this native desktop client for Windows, macOS, and Linux.

Features llava-13b which uses a vision encoder and Vicuna to allow you to discuss the contents of an image with the large language model (LLM). Additionally, it includes an API X-Ray tab so you can easily how the interaction with the API server works.

The AI Vision Chat Desktop client is a powerful UI for allowing you to discuss the contents of an image with a chat bot. 

Built with Delphi using the FireMonkey [cross-platform development](https://www.embarcadero.com/products/delphi/) framework this client works on Windows, macOS, and Linux (and maybe Android+iOS) with a single codebase and single UI. At the moment it is specifically set up for Windows.

It also features a REST integration with Replicate.com for hosting the model used in the client. You need to sign up for an API key to access that functionality. Replicate models can be run in the cloud or locally via docker.

```
docker run -d -p 5000:5000 --gpus=all r8.im/yorickvp/llava-13b@sha256:6bc1c7bb0d2a34e413301fee8f7cc728d2d4e75bfab186aa995f63292bda92fc
curl http://localhost:5000/predictions -X POST \
-H "Content-Type: application/json" \
-d '{"input": {
  "image": "https://url/to/file",
    "prompt": "...",
    "top_p": "...",
    "temperature": "...",
    "max_tokens": "..."
  }}'
```

#AI Vision Chat Desktop client Screeshot on Windows
![AI Vision Chat Desktop client on Windows](/screenshot.png)

Other Delphi AI clients:

[SDXL Inpainting](https://github.com/FMXExpress/SDXL-Inpainting)

[Stable Diffusion Desktop Client](https://github.com/FMXExpress/Stable-Diffusion-Desktop-Client)

[CodeDroidAI](https://github.com/FMXExpress/CodeDroidAI)

[ControlNet Sketch To Image](https://github.com/FMXExpress/ControlNet-Sketch-To-Image)

[AutoBlogAI](https://github.com/FMXExpress/AutoBlogAI)

[AI Code Translator](https://github.com/FMXExpress/AI-Code-Translator)

[AI Playground](https://github.com/FMXExpress/AI-Playground-DesktopClient)

[Song Writer AI](https://github.com/FMXExpress/Song-Writer-AI)

[Stable Diffusion Text To Image Prompts](https://github.com/FMXExpress/Stable-Diffusion-Text-To-Image-Prompts)

[Generative AI Prompts](https://github.com/FMXExpress/Generative-AI-Prompts)

[Dreambooth Desktop Client](https://github.com/FMXExpress/DreamBooth-Desktop-Client)

[Text To Vector Desktop Client](https://github.com/FMXExpress/Text-To-Vector-Desktop-Client)
