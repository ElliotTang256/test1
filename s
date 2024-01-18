import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

// Setup the scene, camera, and renderer
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x333333); // Dark background color

const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
camera.position.set(0, 1, 2);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(window.devicePixelRatio);
renderer.shadowMap.enabled = true; // Enable shadow map
renderer.shadowMap.type = THREE.PCFSoftShadowMap; // Optional: for softer shadows
document.body.appendChild(renderer.domElement);

// Lighting
const keyLight = new THREE.DirectionalLight(0xffffff, 1.0);
keyLight.position.set(-1, 2, 4);
keyLight.castShadow = true; // Enable shadow casting for keyLight
scene.add(keyLight);

const fillLight = new THREE.DirectionalLight(0xffffff, 0.8);
fillLight.position.set(1, 1, 2);
scene.add(fillLight);

const backLight = new THREE.DirectionalLight(0xffffff, 0.7);
backLight.position.set(0, 1, -2);
scene.add(backLight);

const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
scene.add(ambientLight);

// Load environment map for reflections
const textureLoader = new THREE.TextureLoader();
const envMap = textureLoader.load('path_to_your_environment_map.jpg'); // Replace with your image path

// Plane for reflections
const planeGeometry = new THREE.PlaneGeometry(10, 10);
const planeMaterial = new THREE.MeshStandardMaterial({
    color: 0x9e9e9e,
    roughness: 0.3, // Adjust for more or less roughness
    metalness: 0.6, // Adjust for more or less metal-like appearance
    envMap: envMap // Set the environment map for reflections
});
const plane = new THREE.Mesh(planeGeometry, planeMaterial);
plane.rotation.x = -Math.PI / 2;
plane.position.y = -0.5;
plane.receiveShadow = true;
scene.add(plane);

// Model paths
const models = ['model/sword1.gltf', 'model/sword2.gltf', 'model/sword3.gltf'];
let currentModelIndex = 0;

const loader = new GLTFLoader();
let currentModel;

function loadModel(modelPath) {
    loader.load(modelPath, function (gltf) {
        if (currentModel) {
            scene.remove(currentModel);
        }
        currentModel = gltf.scene;
        currentModel.traverse(function (node) {
            if (node.isMesh) {
                node.castShadow = true;
            }
        });
        scene.add(currentModel);
    }, undefined, function (error) {
        console.error('An error happened:', error);
    });
}

loadModel(models[currentModelIndex]);

// OrbitControls with damping and drag speed detection
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.05;

let lastTime = performance.now();
let lastAngle = controls.getAzimuthalAngle();
const swapThreshold = 20; // Adjust the threshold based on testing
let canSwap = true; // Flag to control model swapping
let firstRotationDone = false; // Flag to check if first rotation is done

// Mouse down handler
function onMouseDown() {
    const speed = Math.abs(controls.getAzimuthalAngle() - lastAngle);
    if (firstRotationDone && speed > 0.001) {
        controls.dampingFactor = 0.2; // Increase damping to stop faster
    }
}

// Mouse up handler
function onMouseUp() {
    controls.dampingFactor = 0.05; // Reset damping after mouse up
    firstRotationDone = true; // First rotation completed
}

renderer.domElement.addEventListener('mousedown', onMouseDown);
renderer.domElement.addEventListener('mouseup', onMouseUp);

// Resize handler
window.addEventListener('resize', onWindowResize, false);
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

// Animation loop
function animate() {
    requestAnimationFrame(animate);

    const time = performance.now();
    const delta = (time - lastTime) / 1000;
    lastTime = time;

    const angle = controls.getAzimuthalAngle();
    const speed = Math.abs(angle - lastAngle) / delta;

    if (speed > swapThreshold && canSwap) {
        currentModelIndex = (currentModelIndex + 1) % models.length;
        loadModel(models[currentModelIndex]);
        canSwap = false;
    }

    if (speed < 0.001) {
        canSwap = true;
    }

    lastAngle = angle;

    controls.update();
    renderer.render(scene, camera);
}

animate();