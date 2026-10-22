import * as GaussianSplats3D from "@mkkellogg/gaussian-splats-3d";

const msg = document.getElementById("msg");

// nerfstudio 导出的模型垂直轴为 z，故 cameraUp 用 [0,0,1]
// antialiased:true 对 gsplat 训练的模型启用抗锯齿补偿，消除“玻璃碴子”伪影
const viewer = new GaussianSplats3D.Viewer({
  cameraUp: [0, 0, 1],
  initialCameraPosition: [3, 3, 2],
  initialCameraLookAt: [0, 0, 0],
  antialiased: true,
});

viewer
  .addSplatScene("/splat.ply", {
    splatAlphaRemovalThreshold: 1,
    showLoadingUI: true,
  })
  .then(() => {
    msg.style.display = "none";
    viewer.start();
  })
  .catch((e) => {
    msg.textContent = "加载失败: " + e.message;
    console.error(e);
  });
